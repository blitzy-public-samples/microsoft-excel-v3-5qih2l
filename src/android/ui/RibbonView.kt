package com.microsoft.excel.android.ui

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.HorizontalScrollView
import android.widget.Button
import android.widget.Spinner
import androidx.core.content.ContextCompat
import com.microsoft.excel.android.viewmodels.RibbonViewModel
import com.microsoft.excel.core.models.Style
import com.microsoft.excel.android.utils.ColorUtils

class RibbonView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private lateinit var viewModel: RibbonViewModel
    private lateinit var tabScrollView: HorizontalScrollView
    private lateinit var tabContainer: LinearLayout
    private lateinit var contentContainer: LinearLayout
    private val tabContentViews: MutableMap<String, LinearLayout> = mutableMapOf()

    init {
        viewModel = RibbonViewModel()
        setupUI()
        observeViewModelChanges()
    }

    private fun setupUI() {
        orientation = VERTICAL
        val inflater = LayoutInflater.from(context)
        inflater.inflate(R.layout.ribbon_view, this, true)

        tabScrollView = findViewById(R.id.tabScrollView)
        tabContainer = findViewById(R.id.tabContainer)
        contentContainer = findViewById(R.id.contentContainer)

        createTabs()
        createTabContents()
    }

    private fun createTabs() {
        viewModel.tabs.forEach { tabId ->
            val tabButton = Button(context).apply {
                text = tabId
                setOnClickListener { onTabSelected(tabId) }
            }
            tabContainer.addView(tabButton)
        }
    }

    private fun createTabContents() {
        viewModel.tabs.forEach { tabId ->
            val contentView = createTabContent(tabId)
            tabContentViews[tabId] = contentView
            contentContainer.addView(contentView)
        }
    }

    private fun createTabContent(tabId: String): LinearLayout {
        return when (tabId) {
            "Home" -> createHomeTabContent()
            "Insert" -> createInsertTabContent()
            "Formulas" -> createFormulaTabContent()
            else -> LinearLayout(context) // Empty layout for unknown tabs
        }
    }

    private fun createHomeTabContent(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = HORIZONTAL
            // Add Clipboard group
            addView(createButtonGroup("Clipboard", listOf("Cut", "Copy", "Paste")))
            // Add Font group
            addView(createFontGroup())
            // Add Alignment group
            addView(createButtonGroup("Alignment", listOf("Left", "Center", "Right")))
            // Add Number Format group
            addView(createNumberFormatGroup())
        }
    }

    private fun createInsertTabContent(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = HORIZONTAL
            // Add Tables group
            addView(createButtonGroup("Tables", listOf("Table", "PivotTable")))
            // Add Charts group
            addView(createButtonGroup("Charts", listOf("Column", "Line", "Pie")))
            // Add Illustrations group
            addView(createButtonGroup("Illustrations", listOf("Picture", "Shapes")))
        }
    }

    private fun createFormulaTabContent(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = HORIZONTAL
            // Add Function Library group
            addView(createButtonGroup("Function Library", listOf("Insert Function", "AutoSum", "Recently Used")))
            // Add Defined Names group
            addView(createButtonGroup("Defined Names", listOf("Name Manager", "Define Name")))
            // Add Formula Auditing group
            addView(createButtonGroup("Formula Auditing", listOf("Trace Precedents", "Trace Dependents")))
        }
    }

    private fun createButtonGroup(groupName: String, buttonNames: List<String>): LinearLayout {
        return LinearLayout(context).apply {
            orientation = VERTICAL
            addView(Button(context).apply { text = groupName })
            buttonNames.forEach { buttonName ->
                addView(Button(context).apply { text = buttonName })
            }
        }
    }

    private fun createFontGroup(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = VERTICAL
            addView(Button(context).apply { text = "Font" })
            addView(Spinner(context).apply {
                // TODO: Add font options
            })
            addView(Spinner(context).apply {
                // TODO: Add font size options
            })
            addView(createButtonGroup("", listOf("Bold", "Italic", "Underline")))
        }
    }

    private fun createNumberFormatGroup(): LinearLayout {
        return LinearLayout(context).apply {
            orientation = VERTICAL
            addView(Button(context).apply { text = "Number Format" })
            addView(Spinner(context).apply {
                // TODO: Add number format options
            })
            addView(createButtonGroup("", listOf("Currency", "Percent")))
        }
    }

    private fun onTabSelected(tabId: String) {
        viewModel.selectedTab = tabId
        updateTabContentVisibility()
        updateTabButtonStyles()
    }

    private fun updateTabContentVisibility() {
        tabContentViews.forEach { (id, view) ->
            view.visibility = if (id == viewModel.selectedTab) VISIBLE else GONE
        }
    }

    private fun updateTabButtonStyles() {
        tabContainer.children.forEachIndexed { index, view ->
            if (view is Button) {
                val isSelected = viewModel.tabs[index] == viewModel.selectedTab
                view.isSelected = isSelected
                // TODO: Update button style based on selection state
            }
        }
    }

    private fun observeViewModelChanges() {
        // TODO: Implement observers for ViewModel state changes
    }
}