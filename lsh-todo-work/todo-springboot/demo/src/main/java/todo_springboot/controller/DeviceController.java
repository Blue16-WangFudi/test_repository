package todo_springboot.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.util.StringUtils;
import todo_springboot.config.MqttProperties;
import todo_springboot.dto.MqttCommandRequest;
import todo_springboot.entity.DeviceData;
import todo_springboot.mqtt.MqttSender;
import todo_springboot.service.DeviceDataService;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/device")
public class DeviceController {

    private final MqttSender mqttSender;
    private final DeviceDataService deviceDataService;
    private final MqttProperties mqttProperties;

    /**
     * 前端调用该接口后，后端通过 MQTT 向硬件下发控制指令。
     */
    @PostMapping("/command")
    public Map<String, Object> sendCommand(@RequestBody MqttCommandRequest request) throws Exception {
        Map<String, Object> commandPayload = new LinkedHashMap<>();
        commandPayload.put("deviceId", request.getDeviceId());
        commandPayload.put("command", request.getCommand());
        commandPayload.put("params", request.getParams());
        commandPayload.put("sendTime", LocalDateTime.now());

        String targetTopic = StringUtils.hasText(request.getTopic()) ? request.getTopic() : mqttProperties.getPublishTopic();
        mqttSender.publish(targetTopic, commandPayload);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("topic", targetTopic);
        result.put("payload", commandPayload);
        return result;
    }

    /**
     * 查询设备历史上报数据；deviceId 为空时查询全部设备最新数据。
     */
    @GetMapping("/data")
    public List<DeviceData> listHistory(
            @RequestParam(required = false) String deviceId,
            @RequestParam(defaultValue = "100") int limit
    ) {
        return deviceDataService.listHistory(deviceId, limit);
    }
}
