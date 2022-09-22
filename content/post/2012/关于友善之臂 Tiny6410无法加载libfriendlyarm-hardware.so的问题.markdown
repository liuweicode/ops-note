---
layout: post
title:  关于友善之臂 Tiny6410无法加载libfriendlyarm-hardware.so的问题
date:   2012-12-05
categories: [Java]
no-post-nav: true
---

adb logcat 信息日志如下：

```
D/dalvikvm( 4534): No JNI_OnLoad found in /system/lib/libfriendlyarm-hardware.so 0x40712ca8, skipping init
```

日志信息提示在/system/lib下找不到libfriendlyarm-hardware.so文件，于是我到/system/lib目录下进行查看：

```
liuwei@IT:~/下载$ adb shell
/ # ls /system/lib | grep libfriendlyarm-hardware.so
libfriendlyarm-hardware.so
```

明明这个文件啊，于是我将该文件pull到本地，放到当前的工程的libs/armeabi下，启动之后，还是报错。
最后网上查了很久，原来友善之臂提供的是静态库，路径必须按照指定的来。也就是说，HardwareControler.java这个文件必须在com.friendlyarm.AndroidSDK的包下...

修改之，继续运行，logcat依旧报这个错，但是程序能成功加载libfriendlyarm-hardware.so库了，不知到这是什么原因？

下面是友善之臂 Tiny6410对串口的操作类：完整Deno源码在：

http://download.csdn.net/detail/william548934/4854745

```
package co.liuwei;

import java.util.ArrayList;
import java.util.List;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.friendlyarm.AndroidSDK.HardwareControler;

/**

 * @Description: 串口操作类

 * @Author: Liu wei

 * @date 2012-12-05

 */
public class SerialPortCmd {

    private static final String TAG = "SerialPortCmd";

    public final static int CMD_LENGHT = 8; // 命令长度（固定8个byte）

    private static int serialDevice = -1;//串口描述符
    private static String devName = "/dev/s3c2410_serial3";
    private static long baud = 115200;
    private static int dataBits = 8;
    private static int stopBits = 1;
    private static final int REPEAT_TIMES = 2;

    private static final int MESSAGE_RECEIVED_CMD = 1;

    /**
     * 打开串口
     */
    public static void openSerialPort(){
        if(-1 == serialDevice){
            //打开串口
            serialDevice = HardwareControler.openSerialPort(devName, baud, dataBits, stopBits);
            Log.d(TAG, "打开串口："+serialDevice);
            //打开监听
            listenCmd();
        }else{
            Log.d(TAG, "串口已经打开");
        }

    }
    /**
     * 关闭串口
     */
    public static void closeSerialPort(){
        //关闭串口
        Log.d(TAG, "关闭串口："+serialDevice);
        serialDevice = -1;
        HardwareControler.close(serialDevice);
    }

    private static Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {

            switch (msg.what) {
                case MESSAGE_RECEIVED_CMD:
                    byte[] cmd = (byte[])msg.obj;
                    doCmd(cmd);
                    break;
                default:
                    break;
            }
        }
    };

    public static synchronized void sendControlCmd(final byte[] sendCmd) {

        //串口设备没有打开直接返回
        if (-1 == serialDevice) {
            return;
        }
        setCheckSum(sendCmd);
        SendCmdThread sendCmdThread = new SendCmdThread();
        sendCmdThread.setSendCmd(sendCmd);
        sendCmdThread.setFeedbackCmd(calculateFeedback(sendCmd));
        sendingCmdThreads.add(sendCmdThread);
        sendCmdThread.start();
    }

    public final static byte FUNCNO_FEEDBACK = 0xFF - 256;

    private static byte[] calculateFeedback(byte[] cmd) {

        byte[] feedbackCmd = new byte[cmd.length];
        feedbackCmd[0] = cmd[0];
        feedbackCmd[1] = cmd[1];
        feedbackCmd[2] = FUNCNO_FEEDBACK;
        feedbackCmd[3] = cmd[3];
        feedbackCmd[4] = cmd[2];

        return feedbackCmd;
    }

    private static void setCheckSum(byte[] cmd) {
        int checkSum = 0;
        for (int i = 0; i < cmd.length - 1; i++) {
            checkSum = ((checkSum + cmd) & 255);
        }
        checkSum = (256 - checkSum) % 256;
        if (checkSum < 128) {
            cmd[cmd.length - 1] = (byte)checkSum;
        } else {
            cmd[cmd.length - 1] = (byte)(checkSum - 256);
        }
    }

    public final static byte CMD_START = 0x5A; //命令开始标志

    public static void listenCmd() {
        new Thread() {
            @Override
            public void run() {
                Log.d(TAG, "监听串口："+serialDevice);
                while (true) {
                    try {
                        Thread.sleep(1000);
                        //串口没有打开
                        if (-1 == serialDevice) {
                            Log.d(TAG, "串口已经断开");
                            continue;
                        }else{
                            int result = HardwareControler.select(serialDevice, 2, 0);
                            if (result == 1) {
                                Thread.sleep(100);
                                byte[] buf = new byte[CMD_LENGHT];
                                int n = HardwareControler.read(serialDevice, buf, buf.length);
                                if(-1!=n){
                                    Log.d(TAG, "接收到数据："+toHex(buf));
                                    Message message = new Message();
                                    message.what = MESSAGE_RECEIVED_CMD;
                                    message.obj = buf;
                                    handler.sendMessage(message);
                                }
                            }
                        }
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }

        }.start();
    }

    /**
     * 将字节数组转换为16进制字符串
     *
     * @param buffer
     * @return
     */
    public static String toHex(byte[] buffer) {
        StringBuffer sb = new StringBuffer(buffer.length * 2);
        for (int i = 0; i < buffer.length; i++) {
            sb.append(Character.forDigit((buffer & 240) >> 4, 16));
            sb.append(Character.forDigit(buffer & 15, 16));
            sb.append(" ");
        }
        return sb.toString();
    }

    private static void doCmd(byte[] cmd) {
        //读取的信息中不包含开始位，因此FuncNo位是第二位
        switch (cmd[1]) {
            case FUNCNO_FEEDBACK:
                feedbackCmd(cmd);
                break;
            default:
                break;
        }
    }

    private static synchronized void feedbackCmd(byte[] cmd) {

        for (int i = 0; i < sendingCmdThreads.size(); i++) {
            byte[] feedbackCmd = sendingCmdThreads.get(i).getFeedbackCmd();
            boolean isFeedback = true;
            for (int j = 2; j < feedbackCmd.length - 1; j++) {
                if (cmd[j - 1] != feedbackCmd[j]) {
                    isFeedback = false;
                    break;
                }
            }

            if (isFeedback) {
                sendingCmdThreads.get(i).setHasFeedback(true);
                sendingCmdThreads.remove(i);
                return;
            }
        }
    }

    private static List<SendCmdThread> sendingCmdThreads = new ArrayList<SendCmdThread>();

    private static class SendCmdThread extends Thread {

        private byte[] sendCmd;

        private byte[] feedbackCmd;

        private boolean hasFeedback;

        public SendCmdThread() {

        }

        public void setSendCmd(byte[] sendCmd) {
            this.sendCmd = sendCmd;
        }

        public void setFeedbackCmd(byte[] feedbackCmd) {
            this.feedbackCmd = feedbackCmd;
        }

        public byte[] getFeedbackCmd() {
            return feedbackCmd;
        }

        public void setHasFeedback(boolean hasFeedback) {
            this.hasFeedback = hasFeedback;
        }

        public void run() {
            int repeatTimes = 0;
            while (repeatTimes++ < REPEAT_TIMES) {
                try {
                    Log.d(TAG, "发送命令："+toHex(sendCmd));
                    int result = HardwareControler.write(serialDevice, sendCmd);
                    if(-1 == result){
                        Log.d(TAG, "发送命令失败："+repeatTimes+"次");
                        Thread.sleep(1000);
                    }else{
                        Log.d(TAG, "发送命令成功："+repeatTimes+"次");
                        return;
                    }
                    if (hasFeedback) {
                        Log.d(TAG, "收到了正确的反馈");
                        //收到了正确的反馈，就不用再次发送指令，
                        //否则重复发送指令
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            //若干次未能获得正确的反馈信息，停止发送命令
            Log.d(TAG, "若干次未能获得正确的反馈信息，停止发送命令");
            sendingCmdThreads.remove(this);
        }
    }
}
```

调用很简单，只要在Activity的Button组件的OnClickListener中调用即可，如下：

```
openSerial = (Button) findViewById(R.id.openSerial);
closeSerial = (Button) findViewById(R.id.closeSerial);
sendSerial = (Button) findViewById(R.id.sendSerial);

openSerial.setOnClickListener(new Button.OnClickListener() {
	public void onClick(View v) {
		SerialPortCmd.openSerialPort();
	}
});

sendSerial.setOnClickListener(new Button.OnClickListener() {
	public void onClick(View v) {
		byte[] sendCmd = new byte[] { 0x5a, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x11 };
		SerialPortCmd.sendControlCmd(sendCmd);
	}
});

closeSerial.setOnClickListener(new Button.OnClickListener() {
	@Override
	public void onClick(View v) {
		SerialPortCmd.closeSerialPort();
	}
});
```

在Ubuntu下可使用Cutecom进行通讯调试。
