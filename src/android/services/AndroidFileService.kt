package com.microsoft.excel.android.services

import android.content.Context
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import com.microsoft.excel.core.interfaces.IFileService
import com.microsoft.excel.core.models.Workbook
import com.microsoft.excel.core.datastorage.CellManager
import com.microsoft.excel.android.utils.FileFormatConverter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AndroidFileService(
    private val context: Context,
    private val cellManager: CellManager
) : IFileService {

    override suspend fun openFile(uri: Uri): Workbook? = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                val fileContents = inputStream.readBytes()
                val workbook = FileFormatConverter.convertToWorkbook(fileContents)
                cellManager.updateWorkbook(workbook)
                return@withContext workbook
            }
        } catch (e: Exception) {
            // TODO: Implement proper error logging
            e.printStackTrace()
            return@withContext null
        }
    }

    override suspend fun saveFile(workbook: Workbook, uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            val fileData = FileFormatConverter.convertToFileFormat(workbook)
            context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(fileData)
            }
            return@withContext true
        } catch (e: Exception) {
            // TODO: Implement proper error logging
            e.printStackTrace()
            return@withContext false
        }
    }

    override suspend fun exportToPdf(workbook: Workbook, uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            val pdfData = FileFormatConverter.convertToPdf(workbook)
            context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(pdfData)
            }
            return@withContext true
        } catch (e: Exception) {
            // TODO: Implement proper error logging
            e.printStackTrace()
            return@withContext false
        }
    }

    override suspend fun importFromCsv(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                val csvContents = inputStream.readBytes()
                val workbook = FileFormatConverter.convertCsvToWorkbook(csvContents)
                cellManager.updateWorkbook(workbook)
            }
            return@withContext true
        } catch (e: Exception) {
            // TODO: Implement proper error logging
            e.printStackTrace()
            return@withContext false
        }
    }

    // TODO: Implement pending human tasks
}