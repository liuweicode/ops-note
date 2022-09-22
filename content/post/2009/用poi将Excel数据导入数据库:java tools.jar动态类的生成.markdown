---
layout: post
title:  用poi将Excel数据导入数据库/java tools.jar动态类的生成
date:   2009-12-28
categories: [Java]
no-post-nav: true
---

由于公司对于Excel的导入导出用的比较多，因此这两天想写一个导入导出的小程序，方便以后使用，对于Excel的操作，本人使用的是poi，poi操作Excel非常方便，但有个缺点，对于Excel单元格的格式，poi在org.apache.poi.hssf.usermodel.HSSFCell中定义，大致包括以下几种类型：

HSSFCell.CELL_TYPE_NUMERIC;//数字格式
HSSFCell.CELL_TYPE_STRING;//字符串（默认）
HSSFCell.CELL_TYPE_FORMULA;//公式
HSSFCell.CELL_TYPE_BLANK;//空白
HSSFCell.CELL_TYPE_BOOLEAN;//布尔
HSSFCell.CELL_TYPE_ERROR;//错误

因此在读取Excel中整数的时候，读取上来会出现".0"的情况，查了资料，也csdn发帖，最后还是需要程序处理，不知道哪位高手有更好的办法。这也许是poi的一个bug吧.

下面是我写的一个导入数据库的例子程序：
完整源码请查看：https://github.com/czzl/EXCELTOOL
首先是配置文件config.xml

```

<?xml version="1.0" encoding="UTF-8" ?>
<root>
<!– 数据库连接信息 –>
<db_conection>
<driver_class>
com.microsoft.sqlserver.jdbc.SQLServerDriver
</driver_class>
<url>
jdbc:sqlserver://localhost:1433;databaseName=excelTest
</url>
<user>sa</user>
<pass>123456</pass>
</db_conection>
<!–基础配置信息–>
<base_config>
<!–定义日志文件–>
<log_file>D:\excelImport.log</log_file>
</base_config>
<!– 配置每个Excel文件的导入信息 –>
<Excel path="etc/test.xls">
<!–className:动态创建的类名(默认为DynamicExcel) , sheetName:Excel一张sheet的名字 , table:数据库表名称(必须的) ,index: 表明是第几张sheet(必须的) –>
<sheet className="DynamicExcel" sheetName="sheet1" table="TB_Test1" index="2" autoCommitRowIndex="5">
<column field="orderDate" database_column="orderDate" file_column_index="1"/>
<column field="orderNum" database_column="orderNum" file_column_index="2" />
<column field="model" database_column="model" file_column_index="3" />
<column field="quantity" database_column="quantity" file_column_index="4" />
<column field="remark" database_column="remark" file_column_index="5" />
</sheet>
<sheet className="DynamicExcel2" sheetName="sheet2" table="TB_Test2" index="1" autoCommitRowIndex="1000">
<column field="orderDate" database_column="orderDate" file_column_index="1"/>
<column field="orderNum" database_column="orderNum" file_column_index="2" />
<column field="model" database_column="model" file_column_index="3" />
<column field="quantity" database_column="quantity" file_column_index="4" />
<column field="remark" database_column="remark" file_column_index="5" />
</sheet>
</Excel>
</root>

```

接下来利用jdom解析这个配置文件，然后利用tools.jar动态生成java类并编译：

```

package com.william.excel.utils;

import java.io.File;
import java.io.FileWriter;

/**
 * 该类用于根据etc/config.xml的配置信息动态创建类
 * 创建类的默认名字为"DynamicExcel"
 * @author it2
 *
 */
public class CreateDynamicExcel {
    private String CLASS_NAME="DynamicExcel";//创建动态类的类名,默认为：DynamicExcel
    private String CLASS_FILE = CLASS_NAME + ".java";//创建动态类的文件名（以.java为拓展名）
    private String[] properties;//创建动态类的属性集合
    public CreateDynamicExcel(String className , String[] properties){
        if(className!=null && !"".equals(className.trim())){
            this.CLASS_NAME = className;
            this.CLASS_FILE=className+".java";
        }
        this.properties = properties;
    }
    //动态创建类
    public void createClass() {
        try {
            new File(CLASS_FILE).delete();
            FileWriter fw = new FileWriter(CLASS_FILE, true);
            // 类
            fw.write("public class " + CLASS_NAME + "{");
            for (int i = 0; i < properties.length; i++) {
                String field = properties;
                // 属性
                fw.write("private String " + field + ";");
                String property = field.replace(field.substring(0, 1), field
                        .substring(0, 1).toUpperCase());
                // set方法
                fw.write("public void set" + property + "(String " + field
                        + "){");
                fw.write("this." + field + "=" + field + ";");
                fw.write("}");
                // get方法
                fw.write("public String get" + property + "(){");
                fw.write("return " + field + ";");
                fw.write("}");

            }

            fw.write("}");
            fw.flush();
            fw.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    //动态编译类
    public void compileClass() {
        String filePath = new File(CreateDynamicExcel.class.getClassLoader()
                .getResource("").getFile()).getAbsolutePath();
        String[] source = { "-d", filePath, new String(CLASS_FILE) };
        System.out.println("javac out:"
                + com.sun.tools.javac.Main.compile(source));
    }
}

```

之后用poi读取，并保存在动态类的集合中：

```

package com.william.excel.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

import com.william.excel.config.ColumnConfig;
import com.william.excel.config.Configuration;
import com.william.excel.config.SheetConfig;
import com.william.excel.log.Log;
import com.william.excel.utils.CreateDynamicExcel;
import com.william.excel.utils.DateUtils;
import com.william.excel.utils.ExcelCellUtil;

public class ReadExcel {

    private HSSFWorkbook wb;

    private int rowsCount;
    public ReadExcel(String path) {
        //Log.writeLog("\r\n", true);
        Log.writeLog("—————–"+DateUtils.getLongSysDate()+"—————-",true);
        Log.writeLog("开始读取："+path,true);

        File checkFile = new File(path);
        if (checkFile.exists()) {
            FileInputStream fis;
            try {
                fis = new FileInputStream(path);
                POIFSFileSystem fs = new POIFSFileSystem(fis); // 利用poi读取excel文件流
                this.wb = new HSSFWorkbook(fs); // 读取excel工作簿
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private HSSFSheet getSheet(int sheetIndex) {
        return wb.getSheetAt(sheetIndex);
    }

    @SuppressWarnings("unchecked")
    public void run() {

        List<SheetConfig> sheetConfigs = Configuration.getExcelConfig()
                .getSheets();
        for (SheetConfig sc : sheetConfigs) {// 判断有几张sheet表
            /** ***********创建动态类Start**************** */
            String className = sc.getClassName();
            List<ColumnConfig> cc = sc.getColumns();
            String[] properties = new String[cc.size()];
            for (int i = 0; i < cc.size(); i++) {
                properties = cc.get(i).getField();
            }
            // 根据类名和属性集合创建动态类
            createExcelClass(className, properties);
            /** ***********创建动态类End**************** */
            Class clazz = null;
            try {
                clazz = Class.forName(className);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            // 行循环,并添加到集合中
            HSSFSheet sheet = getSheet(Integer.parseInt(sc.getIndex()) – 1);
            for (int i = 0; i < sheet.getPhysicalNumberOfRows(); i++) {
                rowsCount = i;
                HSSFRow row = sheet.getRow(i); // 取出sheet中的某一行数据
                if (row != null) {
                    Object obj = null;
                    try {
                        obj = clazz.newInstance();
                    } catch (InstantiationException e) {
                        e.printStackTrace();
                    } catch (IllegalAccessException e) {
                        e.printStackTrace();
                    }
                    // 列循环
                    for (int j = 0; j < cc.size(); j++) {
                        HSSFCell cell = row.getCell((short) j);
                        if (cell != null) {
                            if (Integer.parseInt(cc.get(j)
                                    .getFile_column_index()) – 1 == j) {
                                Class params[] = { String.class };
                                Object paramsObj[] = new Object[1];
                                Method thisMethod;
                                String field = null;
                                try {
                                    field = cc.get(j).getField();
                                    field = field.replace(
                                            field.substring(0, 1), field
                                                    .substring(0, 1)
                                                    .toUpperCase());
                                    thisMethod = clazz.getDeclaredMethod("set"
                                            + field, params);
                                    paramsObj[0] = ExcelCellUtil
                                            .getCellStringValue(cell);
                                    thisMethod.invoke(obj, paramsObj);

                                } catch (NoSuchMethodException e) {
                                    Log.writeLog("新创建的动态类没有 set" + field
                                            + " 方法", true);
                                } catch (IllegalAccessException e) {
                                    Log.writeLog("set" + field
                                            + " 方法访问异常,请联系管理员。", true);
                                } catch (InvocationTargetException e) {
                                    Log.writeLog("set" + field
                                            + " 方法反射异常,请联系管理员。", true);
                                }
                            }
                        }
                    }
                    boolean isException = false;
                    if(i%Integer.parseInt(sc.getAutoCommitRowIndex())==0){
                        isException = ExcelToData.insert(sc.getTable(),sc.getColumns(),obj,true);
                    }else if(i==sheet.getPhysicalNumberOfRows()-1){
                        isException = ExcelToData.insert(sc.getTable(),sc.getColumns(),obj,true);
                    }else{
                        isException = ExcelToData.insert(sc.getTable(),sc.getColumns(),obj,false);
                    }
                    if(isException){
                        Log.writeLog(DateUtils.getLongSysDate()+" ERROR:", true);
                        Log.writeLog("第"+i+"次插入或者提交事务发生异常,有可能导致数据不准确！", true);
                    }
                }

            }
            finishRead(sc.getSheetName(),sc.getTable(),rowsCount);
        }
    }

    private void finishRead(String sheetName ,String tableName, int rowsCount){
        Log.writeLog("读取完毕:"+DateUtils.getLongSysDate(),true);
        Log.writeLog("从Excel【"+sheetName+"】导入数据库表【"+tableName+"】"+"【"+(rowsCount+1)+"】条数据",true);
    }
    private void createExcelClass(String className, String[] properties) {
        CreateDynamicExcel dynamicExcel = new CreateDynamicExcel(className,
                properties);
        dynamicExcel.createClass();// 创建动态类
        dynamicExcel.compileClass();// 编译动态类
    }
}

```



