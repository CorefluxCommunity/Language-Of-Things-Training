-- =============================================================================
-- LoT Training Database Initialization
-- =============================================================================
-- This script creates all tables and sample data needed for database route
-- exercises in the LoT training curriculum.
--
-- Tables:
--   - production_records: Production batch tracking
--   - sensor_readings: Time-series sensor data
--   - quality_results: Quality control results
--   - traceability: Part/component traceability
--   - equipment_status: Equipment state tracking
--   - alarms: Alarm history
-- =============================================================================

-- =============================================================================
-- Production Records Table
-- =============================================================================
-- Tracks production batches, quantities, and efficiency metrics
CREATE TABLE IF NOT EXISTS production_records (
    id SERIAL PRIMARY KEY,
    batch_id VARCHAR(50) NOT NULL,
    product_code VARCHAR(50) NOT NULL,
    quantity_produced INTEGER NOT NULL DEFAULT 0,
    quantity_target INTEGER DEFAULT 0,
    operator VARCHAR(100),
    shift VARCHAR(20),
    line_id VARCHAR(50),
    efficiency DECIMAL(5,2),
    completion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for common queries
CREATE INDEX idx_production_batch ON production_records(batch_id);
CREATE INDEX idx_production_date ON production_records(created_at);

-- Sample data for query exercises
INSERT INTO production_records (batch_id, product_code, quantity_produced, quantity_target, operator, shift, line_id, efficiency) VALUES
('BATCH-2025-001', 'WIDGET-A100', 450, 500, 'John Smith', 'Day', 'LINE-01', 90.00),
('BATCH-2025-002', 'WIDGET-A100', 520, 500, 'Jane Doe', 'Night', 'LINE-01', 104.00),
('BATCH-2025-003', 'GADGET-B200', 380, 400, 'John Smith', 'Day', 'LINE-02', 95.00),
('BATCH-2025-004', 'GADGET-B200', 290, 400, 'Mike Johnson', 'Day', 'LINE-02', 72.50),
('BATCH-2025-005', 'WIDGET-A100', 500, 500, 'Jane Doe', 'Night', 'LINE-01', 100.00);

-- =============================================================================
-- Sensor Readings Table
-- =============================================================================
-- Time-series data for sensor readings (temperature, pressure, etc.)
CREATE TABLE IF NOT EXISTS sensor_readings (
    id SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50) NOT NULL,
    sensor_type VARCHAR(30) NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    unit VARCHAR(20),
    location VARCHAR(100),
    quality VARCHAR(20) DEFAULT 'GOOD',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for time-series queries
CREATE INDEX idx_sensor_id ON sensor_readings(sensor_id);
CREATE INDEX idx_sensor_timestamp ON sensor_readings(timestamp);
CREATE INDEX idx_sensor_type ON sensor_readings(sensor_type);

-- Sample sensor data
INSERT INTO sensor_readings (sensor_id, sensor_type, value, unit, location, quality) VALUES
('TEMP-001', 'temperature', 72.5, 'C', 'Line 1 - Station A', 'GOOD'),
('TEMP-001', 'temperature', 73.2, 'C', 'Line 1 - Station A', 'GOOD'),
('TEMP-002', 'temperature', 68.8, 'C', 'Line 1 - Station B', 'GOOD'),
('PRESS-001', 'pressure', 4.5, 'bar', 'Line 1 - Hydraulics', 'GOOD'),
('PRESS-001', 'pressure', 4.7, 'bar', 'Line 1 - Hydraulics', 'GOOD'),
('FLOW-001', 'flow', 125.3, 'L/min', 'Line 2 - Coolant', 'GOOD'),
('VIBR-001', 'vibration', 0.05, 'mm/s', 'Motor A', 'GOOD'),
('VIBR-001', 'vibration', 0.12, 'mm/s', 'Motor A', 'WARNING');

-- =============================================================================
-- Quality Results Table
-- =============================================================================
-- Quality control inspection results
CREATE TABLE IF NOT EXISTS quality_results (
    id SERIAL PRIMARY KEY,
    inspection_id VARCHAR(50) NOT NULL,
    batch_id VARCHAR(50),
    part_id VARCHAR(50),
    inspection_type VARCHAR(50) NOT NULL,
    result VARCHAR(20) NOT NULL,  -- PASS, FAIL, REWORK
    measured_value DECIMAL(10,4),
    target_value DECIMAL(10,4),
    tolerance DECIMAL(10,4),
    inspector VARCHAR(100),
    notes TEXT,
    inspection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for quality queries
CREATE INDEX idx_quality_batch ON quality_results(batch_id);
CREATE INDEX idx_quality_result ON quality_results(result);
CREATE INDEX idx_quality_time ON quality_results(inspection_time);

-- Sample quality data
INSERT INTO quality_results (inspection_id, batch_id, part_id, inspection_type, result, measured_value, target_value, tolerance, inspector) VALUES
('QC-2025-0001', 'BATCH-2025-001', 'PART-001', 'dimensional', 'PASS', 25.02, 25.00, 0.05, 'Quality Tech 1'),
('QC-2025-0002', 'BATCH-2025-001', 'PART-002', 'dimensional', 'PASS', 24.98, 25.00, 0.05, 'Quality Tech 1'),
('QC-2025-0003', 'BATCH-2025-002', 'PART-003', 'dimensional', 'FAIL', 25.12, 25.00, 0.05, 'Quality Tech 2'),
('QC-2025-0004', 'BATCH-2025-002', 'PART-004', 'visual', 'PASS', NULL, NULL, NULL, 'Quality Tech 2'),
('QC-2025-0005', 'BATCH-2025-003', 'PART-005', 'functional', 'REWORK', NULL, NULL, NULL, 'Quality Tech 1');

-- =============================================================================
-- Traceability Table
-- =============================================================================
-- Component and part traceability for manufacturing
CREATE TABLE IF NOT EXISTS traceability (
    id SERIAL PRIMARY KEY,
    part_id VARCHAR(50) NOT NULL UNIQUE,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(50),
    serial_number VARCHAR(100),
    batch_id VARCHAR(50),
    manufacturer VARCHAR(100),
    parent_part_id VARCHAR(50),
    status VARCHAR(30) DEFAULT 'created',
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for traceability queries
CREATE INDEX idx_trace_part ON traceability(part_id);
CREATE INDEX idx_trace_batch ON traceability(batch_id);
CREATE INDEX idx_trace_serial ON traceability(serial_number);

-- Sample traceability data
INSERT INTO traceability (part_id, part_name, part_type, serial_number, batch_id, manufacturer, status, location) VALUES
('PART-001', 'Motor Assembly', 'assembly', 'SN-2025-00001', 'BATCH-2025-001', 'MotorCorp', 'completed', 'Warehouse A'),
('PART-002', 'Control Board', 'electronic', 'SN-2025-00002', 'BATCH-2025-001', 'ElectroniX', 'completed', 'Warehouse A'),
('PART-003', 'Sensor Module', 'electronic', 'SN-2025-00003', 'BATCH-2025-002', 'SensorTech', 'in_progress', 'Line 1'),
('PART-004', 'Housing Unit', 'mechanical', 'SN-2025-00004', 'BATCH-2025-002', 'MetalWorks', 'created', 'Receiving'),
('PART-005', 'Power Supply', 'electronic', 'SN-2025-00005', 'BATCH-2025-003', 'PowerPlus', 'rework', 'QC Station');

-- =============================================================================
-- Equipment Status Table
-- =============================================================================
-- Equipment state and health tracking
CREATE TABLE IF NOT EXISTS equipment_status (
    id SERIAL PRIMARY KEY,
    equipment_id VARCHAR(50) NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_type VARCHAR(50),
    status VARCHAR(30) NOT NULL,  -- RUNNING, STOPPED, MAINTENANCE, FAULT
    runtime_hours DECIMAL(10,2) DEFAULT 0,
    cycle_count INTEGER DEFAULT 0,
    last_maintenance TIMESTAMP,
    next_maintenance TIMESTAMP,
    health_score DECIMAL(5,2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for equipment queries
CREATE INDEX idx_equipment_id ON equipment_status(equipment_id);
CREATE INDEX idx_equipment_status ON equipment_status(status);

-- Sample equipment data
INSERT INTO equipment_status (equipment_id, equipment_name, equipment_type, status, runtime_hours, cycle_count, health_score) VALUES
('EQ-001', 'CNC Machine 1', 'CNC', 'RUNNING', 1250.5, 45230, 92.5),
('EQ-002', 'CNC Machine 2', 'CNC', 'STOPPED', 980.2, 38100, 88.0),
('EQ-003', 'Assembly Robot 1', 'ROBOT', 'RUNNING', 2100.8, 125000, 95.0),
('EQ-004', 'Conveyor Belt A', 'CONVEYOR', 'RUNNING', 5000.0, 0, 78.5),
('EQ-005', 'Press Machine 1', 'PRESS', 'MAINTENANCE', 3200.5, 89500, 65.0);

-- =============================================================================
-- Alarms Table
-- =============================================================================
-- Alarm history and event logging
CREATE TABLE IF NOT EXISTS alarms (
    id SERIAL PRIMARY KEY,
    alarm_id VARCHAR(50) NOT NULL,
    equipment_id VARCHAR(50),
    alarm_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,  -- INFO, WARNING, CRITICAL, EMERGENCY
    message TEXT,
    value DECIMAL(10,4),
    threshold DECIMAL(10,4),
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_by VARCHAR(100),
    acknowledged_at TIMESTAMP,
    cleared BOOLEAN DEFAULT FALSE,
    cleared_at TIMESTAMP,
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for alarm queries
CREATE INDEX idx_alarm_equipment ON alarms(equipment_id);
CREATE INDEX idx_alarm_severity ON alarms(severity);
CREATE INDEX idx_alarm_time ON alarms(triggered_at);
CREATE INDEX idx_alarm_ack ON alarms(acknowledged);

-- Sample alarm data
INSERT INTO alarms (alarm_id, equipment_id, alarm_type, severity, message, value, threshold, acknowledged) VALUES
('ALM-001', 'EQ-001', 'TEMPERATURE_HIGH', 'WARNING', 'Spindle temperature above normal', 85.5, 80.0, TRUE),
('ALM-002', 'EQ-003', 'VIBRATION_HIGH', 'CRITICAL', 'Excessive vibration detected', 0.25, 0.15, FALSE),
('ALM-003', 'EQ-005', 'MAINTENANCE_DUE', 'INFO', 'Scheduled maintenance required', NULL, NULL, FALSE),
('ALM-004', 'EQ-002', 'PRESSURE_LOW', 'WARNING', 'Hydraulic pressure below threshold', 2.8, 3.5, TRUE),
('ALM-005', 'EQ-004', 'BELT_SLIP', 'CRITICAL', 'Conveyor belt slippage detected', NULL, NULL, FALSE);

-- =============================================================================
-- Stored Procedures for Common Operations
-- =============================================================================

-- Function to get latest sensor reading
CREATE OR REPLACE FUNCTION get_latest_sensor_reading(p_sensor_id VARCHAR)
RETURNS TABLE(sensor_id VARCHAR, sensor_type VARCHAR, value DECIMAL, unit VARCHAR, timestamp TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT sr.sensor_id, sr.sensor_type, sr.value, sr.unit, sr.timestamp
    FROM sensor_readings sr
    WHERE sr.sensor_id = p_sensor_id
    ORDER BY sr.timestamp DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get production summary
CREATE OR REPLACE FUNCTION get_production_summary(p_shift VARCHAR DEFAULT NULL)
RETURNS TABLE(shift VARCHAR, total_batches BIGINT, total_produced BIGINT, avg_efficiency DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pr.shift,
        COUNT(*)::BIGINT as total_batches,
        SUM(pr.quantity_produced)::BIGINT as total_produced,
        AVG(pr.efficiency) as avg_efficiency
    FROM production_records pr
    WHERE (p_shift IS NULL OR pr.shift = p_shift)
    GROUP BY pr.shift;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- Grant permissions (for training purposes)
-- =============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lot_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO lot_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO lot_user;

-- =============================================================================
-- Database ready message
-- =============================================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'LoT Training Database initialized!';
    RAISE NOTICE 'Tables created: production_records, sensor_readings,';
    RAISE NOTICE '               quality_results, traceability,';
    RAISE NOTICE '               equipment_status, alarms';
    RAISE NOTICE 'Sample data loaded for exercises.';
    RAISE NOTICE '========================================';
END $$;
