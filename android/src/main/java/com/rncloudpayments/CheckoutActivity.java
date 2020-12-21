package com.rncloudpayments;

import android.app.Activity;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import ru.cloudpayments.sdk.three_ds.ThreeDSDialogListener;
import ru.cloudpayments.sdk.three_ds.ThreeDsDialogFragment;

public class CheckoutActivity extends AppCompatActivity implements ThreeDSDialogListener {

    static String acsUrl;
    static String paReq;
    static String transactionId;
    static Promise promise;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final ThreeDsDialogFragment dialog = ThreeDsDialogFragment.newInstance(acsUrl, transactionId, paReq);
        dialog.show(getSupportFragmentManager(), "3DS");

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                dialog.getView().addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                    @Override
                    public void onViewAttachedToWindow(View v) {
                    }

                    @Override
                    public void onViewDetachedFromWindow(View v) {
                        promise.reject("Cancel");

                        promise = null;

                        finish();
                    }
                });
            }
        },50);

    }

    @Override
    public void onAuthorizationCompleted(String md, String paRes) {
        WritableMap map = Arguments.createMap();

        map.putString("MD", md);
        map.putString("PaRes", paRes);

        promise.resolve(map);
    }

    @Override
    public void onAuthorizationFailed(String html) {
        promise.reject(html);
    }
}
