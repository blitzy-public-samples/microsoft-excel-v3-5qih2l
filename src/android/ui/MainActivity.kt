package com.microsoft.excel.android.ui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.NavController
import androidx.navigation.Navigation
import com.microsoft.excel.android.viewmodels.MainViewModel
import com.microsoft.excel.core.calculation.CalculationEngine
import com.microsoft.excel.core.datastorage.CellManager
import com.microsoft.excel.core.collaboration.RealTimeSync
import com.microsoft.excel.android.services.AndroidFileService
import com.microsoft.excel.android.services.AndroidClipboardService
import com.microsoft.excel.android.ui.fragments.WorksheetFragment
import com.microsoft.excel.android.ui.fragments.RibbonFragment
import com.microsoft.excel.android.R

class MainActivity : AppCompatActivity() {

    private lateinit var viewModel: MainViewModel
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize ViewModel
        viewModel = ViewModelProvider(this).get(MainViewModel::class.java)

        // Set up navigation
        setupNavigation()

        // Initialize ActionBar
        setSupportActionBar(findViewById(R.id.toolbar))

        // Set up bottom navigation if applicable
        // findViewById<BottomNavigationView>(R.id.bottom_nav)?.setupWithNavController(navController)

        // Initialize core components
        val calculationEngine = CalculationEngine()
        val cellManager = CellManager()
        val realTimeSync = RealTimeSync()

        // Initialize services
        val fileService = AndroidFileService(this)
        val clipboardService = AndroidClipboardService(this)

        // Set up ViewModel with core components and services
        viewModel.initialize(calculationEngine, cellManager, realTimeSync, fileService, clipboardService)

        // Set up observers for ViewModel state changes
        setupObservers()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_new -> {
                viewModel.createNewWorkbook()
                true
            }
            R.id.action_open -> {
                viewModel.openWorkbook()
                true
            }
            R.id.action_save -> {
                viewModel.saveWorkbook()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupNavigation() {
        val navHostFragment = supportFragmentManager.findFragmentById(R.id.nav_host_fragment)
        navController = Navigation.findNavController(this, R.id.nav_host_fragment)
    }

    fun handleCellSelection(position: CellPosition) {
        viewModel.selectCell(position)
        updateFormulaBar()
        updateRibbonUI()
    }

    fun handleFormulaBarEdit(newFormula: String) {
        viewModel.updateFormula(newFormula)
        viewModel.recalculateActiveCell()
        updateWorksheetUI()
    }

    private fun setupObservers() {
        viewModel.activeWorkbook.observe(this) { workbook ->
            // Update UI based on active workbook changes
        }

        viewModel.selectedCell.observe(this) { cell ->
            // Update UI based on selected cell changes
        }
    }

    private fun updateFormulaBar() {
        // Update formula bar UI with selected cell's formula
    }

    private fun updateRibbonUI() {
        // Update ribbon UI based on selected cell's formatting
    }

    private fun updateWorksheetUI() {
        // Update worksheet UI to reflect changes
    }
}