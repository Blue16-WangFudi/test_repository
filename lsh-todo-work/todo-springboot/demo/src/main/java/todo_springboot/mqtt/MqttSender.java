package todo_springboot.mqtt;

import lombok.RequiredArgsConstructor;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import tools.jackson.databind.ObjectMapper;
import todo_springboot.config.MqttProperties;

import java.nio.charset.StandardCharsets;

@Component
@RequiredArgsConstructor
public class MqttSender {

    private final MqttClient mqttClient;
    private final MqttProperties mqttProperties;
    private final ObjectMapper objectMapper;

    public void publish(Object payload) throws Exception {
        publish(mqttProperties.getPublishTopic(), payload);
    }

    public void publish(String topic, Object payload) throws Exception {
        if (!mqttClient.isConnected()) {
            throw new IllegalStateException("MQTT client is not connected");
        }

        String targetTopic = StringUtils.hasText(topic) ? topic : mqttProperties.getPublishTopic();
        String payloadText = payload instanceof String text ? text : objectMapper.writeValueAsString(payload);

        MqttMessage message = new MqttMessage(payloadText.getBytes(StandardCharsets.UTF_8));
        message.setQos(mqttProperties.getQos());
        message.setRetained(false);
        mqttClient.publish(targetTopic, message);
    }
}
