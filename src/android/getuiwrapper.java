package com.pluswave.getui.wrapper;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.igexin.sdk.PushManager;
import android.util.Log;

/**
 * This class echoes a string called from JavaScript.
 */
public class getuiwrapper extends CordovaPlugin {

    private static CordovaWebView gWebView;
    private static String gECB = "window.plugins.getuiwrapper.messageReceived";
    
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // your init code here

        PushManager.getInstance().initialize(cordova.getActivity().getApplicationContext());
        gWebView = webView;
    }
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        // gWebView = this.webView;
        if (action.equals("coolMethod")) {
            String message = args.getString(0);
            this.coolMethod(message, callbackContext);
            return true;
        }
        if( action.equals("getClientID")){
            if( PushReceiver.gClientid != null ){
                callbackContext.success(PushReceiver.gClientid);
            }
            else{
                callbackContext.error("GetuiSDK: Initialize not complete");
            }
            return true;
        }
        return false;
    }

    private void coolMethod(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }

    /*
     * Sends a json object to the client as parameter to a method which is defined in gECB.
     */
    public static void sendJavascript(JSONObject _json) {
        String _d = "javascript:" + gECB + "(" + _json.toString() + ")";
        Log.v("getuiwrapper", "sendJavascript: " + _d);

        if (gECB != null && gWebView != null) {
            gWebView.sendJavascript(_d);
        }
    }
    
}
