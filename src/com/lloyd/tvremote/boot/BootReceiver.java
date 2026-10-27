package com.lloyd.tvremote.boot;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "TVRemoteBoot";

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent != null ? intent.getAction() : "";
        Log.i(TAG, "Boot event received: " + action);
        new Thread(new Runnable() {
            @Override
            public void run() {
                startServerAsRoot();
            }
        }).start();
    }

    public static void startServerAsRoot() {
        for (int retry = 0; retry < 15; retry++) {
            Socket socket = null;
            try {
                Thread.sleep(1000);
                socket = new Socket("127.0.0.1", 5555);
                socket.setSoTimeout(5000);
                OutputStream out = socket.getOutputStream();
                InputStream in = socket.getInputStream();

                // 1. Send CNXN
                byte[] hostPayload = "host::\0".getBytes("UTF-8");
                sendPacket(out, 0x4e584e43, 0x01000000, 4096, hostPayload);

                // Read CNXN response
                byte[] hdr = readExact(in, 24);
                ByteBuffer bb = ByteBuffer.wrap(hdr).order(ByteOrder.LITTLE_ENDIAN);
                bb.getInt(); // cmd
                bb.getInt(); // arg0
                bb.getInt(); // arg1
                int rlen = bb.getInt();
                if (rlen > 0) {
                    readExact(in, rlen);
                }

                // 2. Send OPEN for shell command
                byte[] cmdPayload = "shell:/system/bin/busybox httpd -p 8080 -h /data/local/tmp/remote\0".getBytes("UTF-8");
                sendPacket(out, 0x4e45504f, 1, 0, cmdPayload);

                // Read OPEN response
                readExact(in, 24);
                Thread.sleep(1000);

                Log.i(TAG, "Root daemon launched successfully via localhost adb!");
                break;
            } catch (Exception e) {
                Log.w(TAG, "Attempt " + retry + " failed: " + e.getMessage());
            } finally {
                if (socket != null) {
                    try { socket.close(); } catch (Exception ignored) {}
                }
            }
        }
    }

    private static void sendPacket(OutputStream out, int cmd, int arg0, int arg1, byte[] payload) throws Exception {
        int length = payload != null ? payload.length : 0;
        int crc = 0;
        if (payload != null) {
            for (byte b : payload) {
                crc += (b & 0xFF);
            }
        }
        int magic = cmd ^ 0xFFFFFFFF;

        ByteBuffer buf = ByteBuffer.allocate(24 + length).order(ByteOrder.LITTLE_ENDIAN);
        buf.putInt(cmd);
        buf.putInt(arg0);
        buf.putInt(arg1);
        buf.putInt(length);
        buf.putInt(crc);
        buf.putInt(magic);
        if (payload != null) {
            buf.put(payload);
        }
        out.write(buf.array());
        out.flush();
    }

    private static byte[] readExact(InputStream in, int len) throws Exception {
        byte[] b = new byte[len];
        int off = 0;
        while (off < len) {
            int r = in.read(b, off, len - off);
            if (r < 0) throw new Exception("Socket EOF");
            off += r;
        }
        return b;
    }
}
