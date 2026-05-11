package todo_springboot.dto;

import lombok.Data;

import java.util.Map;

@Data
public class MqttCommandRequest {

    private String deviceId;

    private String command;

    /**
     * 可选：不传时使用 application.yaml 中 mqtt.publish-topic。
     */
    private String topic;

    private Map<String, Object> params;
}
