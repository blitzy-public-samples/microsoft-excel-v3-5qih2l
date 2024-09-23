import React, { useState, useContext } from 'react';
import { AppBar, Tabs, Tab, Toolbar, IconButton, Menu, MenuItem } from '@material-ui/core';
import { Home, InsertChart, Functions, DataUsage, Save, Print, Undo, Redo } from '@material-ui/icons';
import { AppContext } from '../context/AppContext';
import { ExcelService } from '../services/ExcelService';
import '../styles/Ribbon.css';

const Ribbon: React.FC = () => {
  const [selectedTab, setSelectedTab] = useState(0);
  const [menuAnchor, setMenuAnchor] = useState<null | HTMLElement>(null);
  const { workbook, updateWorkbook } = useContext(AppContext);

  const handleTabChange = (event: React.ChangeEvent<{}>, newValue: number) => {
    setSelectedTab(newValue);
  };

  const handleMenuOpen = (event: React.MouseEvent<HTMLButtonElement>) => {
    setMenuAnchor(event.currentTarget);
  };

  const handleMenuClose = () => {
    setMenuAnchor(null);
  };

  const handleSave = () => {
    ExcelService.saveWorkbook(workbook);
    handleMenuClose();
  };

  const handlePrint = () => {
    ExcelService.printWorkbook(workbook);
    handleMenuClose();
  };

  const handleUndo = () => {
    updateWorkbook(ExcelService.undoAction(workbook));
  };

  const handleRedo = () => {
    updateWorkbook(ExcelService.redoAction(workbook));
  };

  return (
    <div className="ribbon">
      <AppBar position="static" color="default">
        <Toolbar>
          <IconButton edge="start" color="inherit" aria-label="menu" onClick={handleMenuOpen}>
            <Home />
          </IconButton>
          <Menu
            anchorEl={menuAnchor}
            keepMounted
            open={Boolean(menuAnchor)}
            onClose={handleMenuClose}
          >
            <MenuItem onClick={handleSave}>
              <Save fontSize="small" /> Save
            </MenuItem>
            <MenuItem onClick={handlePrint}>
              <Print fontSize="small" /> Print
            </MenuItem>
          </Menu>
          <IconButton color="inherit" onClick={handleUndo}>
            <Undo />
          </IconButton>
          <IconButton color="inherit" onClick={handleRedo}>
            <Redo />
          </IconButton>
          <Tabs value={selectedTab} onChange={handleTabChange}>
            <Tab label="Home" />
            <Tab label="Insert" />
            <Tab label="Formulas" />
            <Tab label="Data" />
          </Tabs>
        </Toolbar>
      </AppBar>
      {selectedTab === 0 && <HomeTab />}
      {selectedTab === 1 && <InsertTab />}
      {selectedTab === 2 && <FormulasTab />}
      {selectedTab === 3 && <DataTab />}
    </div>
  );
};

const HomeTab: React.FC = () => {
  return (
    <div className="ribbon-tab">
      <div className="ribbon-group">
        <button>Cut</button>
        <button>Copy</button>
        <button>Paste</button>
      </div>
      <div className="ribbon-group">
        <select>
          <option>Arial</option>
          <option>Calibri</option>
          <option>Times New Roman</option>
        </select>
        <select>
          <option>8</option>
          <option>10</option>
          <option>12</option>
          <option>14</option>
        </select>
        <button>B</button>
        <button>I</button>
        <button>U</button>
      </div>
      <div className="ribbon-group">
        <button>Left</button>
        <button>Center</button>
        <button>Right</button>
        <button>Justify</button>
      </div>
      <div className="ribbon-group">
        <button>General</button>
        <button>Number</button>
        <button>Currency</button>
        <button>Percentage</button>
      </div>
    </div>
  );
};

const InsertTab: React.FC = () => {
  return (
    <div className="ribbon-tab">
      <div className="ribbon-group">
        <button>Table</button>
        <button>PivotTable</button>
      </div>
      <div className="ribbon-group">
        <button>Column Chart</button>
        <button>Bar Chart</button>
        <button>Pie Chart</button>
        <button>Line Chart</button>
      </div>
      <div className="ribbon-group">
        <button>Image</button>
        <button>Shape</button>
      </div>
    </div>
  );
};

const FormulasTab: React.FC = () => {
  return (
    <div className="ribbon-tab">
      <div className="ribbon-group">
        <button>Insert Function</button>
      </div>
      <div className="ribbon-group">
        <button>AutoSum</button>
      </div>
      <div className="ribbon-group">
        <button>Financial</button>
        <button>Logical</button>
        <button>Text</button>
        <button>Date & Time</button>
      </div>
    </div>
  );
};

const DataTab: React.FC = () => {
  return (
    <div className="ribbon-tab">
      <div className="ribbon-group">
        <button>Sort</button>
        <button>Filter</button>
      </div>
      <div className="ribbon-group">
        <button>Data Validation</button>
      </div>
      <div className="ribbon-group">
        <button>Text to Columns</button>
        <button>Remove Duplicates</button>
      </div>
    </div>
  );
};

export default Ribbon;