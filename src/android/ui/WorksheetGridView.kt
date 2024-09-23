package com.microsoft.excel.android.ui

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.GridLayout
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.GridLayoutManager
import com.microsoft.excel.android.viewmodels.WorksheetGridViewModel
import com.microsoft.excel.core.models.Cell
import com.microsoft.excel.core.models.CellRange
import com.microsoft.excel.core.datastorage.CellManager
import com.microsoft.excel.android.utils.CellFormatter
import com.microsoft.excel.android.adapters.CellAdapter

class WorksheetGridView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    private lateinit var viewModel: WorksheetGridViewModel
    private lateinit var recyclerView: RecyclerView
    private lateinit var cellAdapter: CellAdapter
    private lateinit var headerLayout: GridLayout
    private var rowCount: Int = 1000
    private var columnCount: Int = 26

    init {
        setupUI()
        setupObservers()
    }

    private fun setupUI() {
        val inflater = LayoutInflater.from(context)
        inflater.inflate(R.layout.view_worksheet_grid, this, true)

        recyclerView = findViewById(R.id.recyclerViewCells)
        headerLayout = findViewById(R.id.gridLayoutHeaders)

        val layoutManager = GridLayoutManager(context, columnCount)
        recyclerView.layoutManager = layoutManager

        cellAdapter = CellAdapter(rowCount, columnCount) { row, column ->
            onCellSelected(row, column)
        }
        recyclerView.adapter = cellAdapter

        setupHeaders()
        setupGridLines()
    }

    private fun setupHeaders() {
        // Create column headers (A, B, C, etc.)
        for (i in 0 until columnCount) {
            val columnHeader = LayoutInflater.from(context).inflate(R.layout.item_header, headerLayout, false)
            columnHeader.text = ('A' + i).toString()
            headerLayout.addView(columnHeader)
        }

        // Create row headers (1, 2, 3, etc.)
        for (i in 1..rowCount) {
            val rowHeader = LayoutInflater.from(context).inflate(R.layout.item_header, headerLayout, false)
            rowHeader.text = i.toString()
            headerLayout.addView(rowHeader)
        }

        // Set up scroll listeners to sync headers with grid scrolling
        recyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                headerLayout.scrollBy(-dx, -dy)
            }
        })
    }

    private fun setupGridLines() {
        recyclerView.addItemDecoration(GridItemDecoration(context))
    }

    private fun setupObservers() {
        viewModel.selectedCell.observe(this) { cell ->
            // Update UI to highlight the selected cell
            cellAdapter.setSelectedCell(cell)
        }

        viewModel.cellData.observe(this) { cellData ->
            cellAdapter.updateData(cellData)
        }
    }

    fun onCellSelected(row: Int, column: Int) {
        viewModel.selectCell(row, column)
        // Notify parent activity or fragment about cell selection
        (context as? CellSelectionListener)?.onCellSelected(row, column)
    }

    fun updateCellValue(newValue: String, row: Int, column: Int) {
        viewModel.updateCellValue(newValue, row, column)
        cellAdapter.notifyItemChanged(row * columnCount + column)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val cellSize = resources.getDimensionPixelSize(R.dimen.cell_size)
        val headerSize = resources.getDimensionPixelSize(R.dimen.header_size)

        val desiredWidth = columnCount * cellSize + headerSize
        val desiredHeight = rowCount * cellSize + headerSize

        val width = resolveSize(desiredWidth, widthMeasureSpec)
        val height = resolveSize(desiredHeight, heightMeasureSpec)

        setMeasuredDimension(width, height)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)

        val cellSize = resources.getDimensionPixelSize(R.dimen.cell_size)
        val headerSize = resources.getDimensionPixelSize(R.dimen.header_size)

        val availableWidth = w - headerSize
        val availableHeight = h - headerSize

        val visibleColumns = availableWidth / cellSize
        val visibleRows = availableHeight / cellSize

        (recyclerView.layoutManager as GridLayoutManager).spanCount = visibleColumns
        cellAdapter.updateVisibleCells(visibleRows, visibleColumns)
    }

    interface CellSelectionListener {
        fun onCellSelected(row: Int, column: Int)
    }
}