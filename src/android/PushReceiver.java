package com.pluswave.getui.wrapper;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.igexin.sdk.PushConsts;
import com.igexin.sdk.PushManager;

public class PushReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        Log.d("PushReceiver", "onReceive() action=" + bundle.getInt("action"));

        switch (bundle.getInt(PushConsts.CMD_ACTION)) {
        case PushConsts.GET_MSG_DATA:
            // 获取透传数据
            byte[] payload = bundle.getByteArray("payload");

            break;
        case PushConsts.GET_CLIENTID:
            String cid = bundle.getString("clientid");

            break;

        case PushConsts.THIRDPART_FEEDBACK:
 
            break;

        default:
            break;
        }


    }



};

