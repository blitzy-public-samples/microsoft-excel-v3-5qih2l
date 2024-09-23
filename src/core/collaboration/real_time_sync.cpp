#include <vector>
#include <unordered_map>
#include <string>
#include <chrono>
#include <thread>
#include <mutex>
#include <atomic>
#include <memory>
#include "real_time_sync.hpp"
#include "../data_storage/cell_manager.hpp"
#include "../security/authentication.hpp"
#include "../models/change.hpp"
#include "../utils/websocket_manager.hpp"

const int SYNC_INTERVAL_MS = 100;
const int MAX_RETRY_ATTEMPTS = 3;

RealTimeSync::RealTimeSync(std::shared_ptr<CellManager> cellManager,
                           std::shared_ptr<Authentication> auth,
                           std::shared_ptr<WebSocketManager> wsManager)
    : m_cellManager(cellManager),
      m_auth(auth),
      m_wsManager(wsManager),
      m_isRunning(false) {}

void RealTimeSync::start() {
    m_isRunning = true;
    std::thread syncThread(&RealTimeSync::syncLoop, this);
    syncThread.detach();
}

void RealTimeSync::stop() {
    m_isRunning = false;
    // Wait for the sync thread to finish (implementation omitted)
}

bool RealTimeSync::applyChange(const Change& change) {
    std::lock_guard<std::mutex> lock(m_changeMutex);
    
    if (m_cellManager->updateCell(change)) {
        m_pendingChanges[change.getUserId()].push_back(change);
        m_wsManager->broadcastChange(change);
        return true;
    }
    return false;
}

void RealTimeSync::handleIncomingChange(const Change& change) {
    std::lock_guard<std::mutex> lock(m_changeMutex);
    
    auto& userChanges = m_pendingChanges[change.getUserId()];
    bool hasConflict = false;
    
    for (auto& pendingChange : userChanges) {
        if (pendingChange.conflictsWith(change)) {
            hasConflict = true;
            Change resolvedChange = resolveConflict(pendingChange, change);
            m_cellManager->updateCell(resolvedChange);
            pendingChange = resolvedChange;
        }
    }
    
    if (!hasConflict) {
        m_cellManager->updateCell(change);
        userChanges.push_back(change);
    }
}

void RealTimeSync::syncLoop() {
    while (m_isRunning) {
        std::vector<Change> changesToSync;
        
        {
            std::lock_guard<std::mutex> lock(m_changeMutex);
            for (auto& userChanges : m_pendingChanges) {
                changesToSync.insert(changesToSync.end(), userChanges.second.begin(), userChanges.second.end());
                userChanges.second.clear();
            }
        }
        
        for (const auto& change : changesToSync) {
            // Send change to server (implementation omitted)
        }
        
        // Handle incoming changes from server (implementation omitted)
        
        std::this_thread::sleep_for(std::chrono::milliseconds(SYNC_INTERVAL_MS));
    }
}

Change resolveConflict(const Change& localChange, const Change& remoteChange) {
    if (localChange.getTimestamp() < remoteChange.getTimestamp()) {
        // Transform localChange against remoteChange
        return localChange.transform(remoteChange);
    } else {
        // Keep localChange as is
        return localChange;
    }
}