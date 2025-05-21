<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 0);

try {
    // Kết nối database
    $conn = new mysqli("localhost", "root", "", "test");
    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Lấy dữ liệu cảm biến mới nhất
        $sql = "SELECT temperature, humidity, air_quality FROM sensor_data
                ORDER BY timestamp DESC LIMIT 1";
        $result = $conn->query($sql);
        
        if ($result === false) {
            throw new Exception('Query failed: ' . $conn->error);
        }
        
        if ($result->num_rows > 0) {
            $sensor_data = $result->fetch_assoc();
        } else {
            $sensor_data = [
                'temperature' => 0,
                'humidity' => 0,
                'air_quality' => 0
            ];
        }

        // Lấy dữ liệu nước mới nhất từ ocr_results
        $sql = "SELECT ocr_text, water_bill, timestamp FROM ocr_results ORDER BY timestamp DESC";
        $result = $conn->query($sql);
        
        if ($result === false) {
            throw new Exception('Query failed: ' . $conn->error);
        }
        
        $all_readings = [];
        while ($row = $result->fetch_assoc()) {
            $all_readings[] = [
                'ocr_text' => $row['ocr_text'],
                'water_bill' => floatval($row['water_bill']),
                'timestamp' => $row['timestamp']
            ];
        }

        $latest_reading = count($all_readings) > 0 ? $all_readings[0] : [
            'ocr_text' => '0',
            'water_bill' => 0,
            'timestamp' => date('Y-m-d H:i:s')
        ];
        
        $data = [
            'status' => 'success',
            'sensor_data' => [
                'latest' => [
                    'temperature' => floatval($sensor_data['temperature']),
                    'humidity' => floatval($sensor_data['humidity']),
                    'air_quality' => floatval($sensor_data['air_quality'])
                ]
            ],
            'water_data' => [
                'latest_reading' => $latest_reading,
                'all_readings' => $all_readings
            ]
        ];
        
        echo json_encode($data);
    } else {
        throw new Exception('Method not allowed');
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

if (isset($conn)) {
    $conn->close();
}
