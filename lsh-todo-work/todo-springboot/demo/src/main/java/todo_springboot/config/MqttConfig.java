package todo_springboot.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import todo_springboot.mqtt.MqttMessageListener;

@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(MqttProperties.class)
public class MqttConfig {

    private final MqttProperties mqttProperties;
    private final MqttMessageListener mqttMessageListener;

    @Bean
    public MqttClient mqttClient() throws Exception {
        return new MqttClient(
                mqttProperties.getServerUri(),
                mqttProperties.getClientId(),
                new MemoryPersistence()
        );
    }

    @Bean
    public MqttConnectOptions mqttConnectOptions() {
        MqttConnectOptions options = new MqttConnectOptions();
        options.setCleanSession(mqttProperties.isCleanSession());
        options.setAutomaticReconnect(mqttProperties.isAutomaticReconnect());
        options.setConnectionTimeout(mqttProperties.getConnectionTimeout());
        options.setKeepAliveInterval(mqttProperties.getKeepAliveInterval());

        if (mqttProperties.getUsername() != null && !mqttProperties.getUsername().isBlank()) {
            options.setUserName(mqttProperties.getUsername());
        }
        if (mqttProperties.getPassword() != null && !mqttProperties.getPassword().isBlank()) {
            options.setPassword(mqttProperties.getPassword().toCharArray());
        }
        return options;
    }

    @Bean
    public ApplicationRunner mqttApplicationRunner(MqttClient mqttClient, MqttConnectOptions mqttConnectOptions) {
        return args -> {
            mqttClient.setCallback(mqttMessageListener);
            try {
                if (!mqttClient.isConnected()) {
                    mqttClient.connect(mqttConnectOptions);
                }
                mqttClient.subscribe(mqttProperties.getSubscribeTopic(), mqttProperties.getQos());
                log.info("MQTT connected: {}, subscribed: {}", mqttProperties.getServerUri(), mqttProperties.getSubscribeTopic());
            } catch (Exception ex) {
                log.warn("MQTT connect failed, application will keep running: {}", mqttProperties.getServerUri(), ex);
            }
        };
    }
}
