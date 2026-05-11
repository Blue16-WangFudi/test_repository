package todo_springboot.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class SensorReportPayload {

    private String deviceId;

    private BigDecimal temperature;

    private BigDecimal humidity;

    /**
     * 硬件可传 ISO-8601 格式时间，例如 2026-05-08T12:00:00；为空时后端使用当前时间。
     */
    private LocalDateTime reportTime;
}
