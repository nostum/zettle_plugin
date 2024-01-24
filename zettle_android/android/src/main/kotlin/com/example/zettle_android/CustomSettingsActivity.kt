package com.example.zettle_android
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.View
import android.widget.TextView
import android.widget.Button
import androidx.appcompat.widget.Toolbar
import android.graphics.Color
import android.util.TypedValue

import com.zettle.sdk.feature.cardreader.ui.CardReaderAction
import com.zettle.sdk.features.show
import com.zettle.sdk.ZettleSDK
import com.zettle.sdk.core.auth.User

class CustomSettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_custom_view)

        ZettleSDK.instance?.authState?.observe(this) { state ->
            onAuthStateChanged(state is User.AuthState.LoggedIn)
        }

        val btnOption1 = findViewById<Button>(R.id.btnOption1)
        btnOption1.setOnClickListener { login() }

        val toolbar = findViewById<Toolbar>(R.id.toolbar);

        toolbar.setNavigationOnClickListener {
            onBackPressed();
        }
        // Mostrar el botón de retroceso en la barra de herramientas
        getSupportActionBar()?.setDisplayHomeAsUpEnabled(true);
        getSupportActionBar()?.setDisplayShowHomeEnabled(true);

        val btnOption2 = findViewById<Button>(R.id.btnOption2)
        btnOption2.setOnClickListener { logout() }
       

        val btnOption3 = findViewById<Button>(R.id.btnOption3)
        btnOption3.setOnClickListener { showSettings() }
    }

    fun login() {
        ZettleSDK.instance?.login(this)
    }

    fun logout() {
        ZettleSDK.instance?.logout()
    }

    fun showSettings() {
      startActivity(CardReaderAction.Settings.show(this))
    }

    private fun onAuthStateChanged(isLoggedIn: Boolean) {
        val btnOption1 = findViewById<Button>(R.id.btnOption1)
        val btnOption2 = findViewById<Button>(R.id.btnOption2)
        val textViewDescription = findViewById<TextView>(R.id.textViewDescription)

        if(isLoggedIn) {
            btnOption1.visibility = View.GONE
            btnOption2.visibility = View.VISIBLE
            textViewDescription.text = "Finaliza tu sesión de Zettle haciendo clic en el botón a continuación."
        } else {
            btnOption2.visibility = View.GONE
            btnOption1.visibility = View.VISIBLE
            textViewDescription.text = "Para comenzar a aceptar pagos con tarjeta, por favor, inicia sesión con tu cuenta de Zettle."
        }
           
    }
}
