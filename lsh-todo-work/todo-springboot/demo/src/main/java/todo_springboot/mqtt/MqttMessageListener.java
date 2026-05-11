package todo_springboot.mqtt;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallbackExtended;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;
import todo_springboot.dto.SensorReportPayload;
import todo_springboot.entity.DeviceData;
import todo_springboot.service.DeviceDataService;
import todo_springboot.websocket.DeviceWebSocketServer;

import java.nio.charset.StandardCharsets;

@Slf4j
@Component
@RequiredArgsConstructor
public class MqttMessageListener implements MqttCallbackExtended {

    private final ObjectMapper objectMapper;
    private final DeviceDataService deviceDataService;

    @Override
    public void connectComplete(boolean reconnect, String serverURI) {
        log.info("MQTT connect complete, reconnect: {}, server: {}", reconnect, serverURI);
    }

    @Override
    public void connectionLost(Throwable cause) {
        log.warn("MQTT connection lost", cause);
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) throws Exception {
        String payloadText = new String(message.getPayload(), StandardCharsets.UTF_8);
        log.info("MQTT received, topic: {}, payload: {}", topic, payloadText);

        SensorReportPayload payload = objectMapper.readValue(payloadText, SensorReportPayload.class);
        DeviceData savedData = deviceDataService.saveReport(payload);

        String websocketMessage = objectMapper.writeValueAsString(savedData);
        DeviceWebSocketServer.broadcast(websocketMessage);
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        log.debug("MQTT delivery complete: {}", token.getMessageId());
    }
}
