package todo_springboot.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "mqtt")
public class MqttProperties {

    /**
     * MQTT Broker 主机地址，不需要写 tcp:// 前缀。
     */
    private String host;

    private int port = 1883;

    private String username;

    private String password;

    private String clientId = "springboot-iot-core";

    private String subscribeTopic = "device/+/report";

    private String publishTopic = "device/control";

    private int qos = 1;

    private int connectionTimeout = 10;

    private int keepAliveInterval = 30;

    private boolean automaticReconnect = true;

    private boolean cleanSession = true;

    public String getServerUri() {
        return "tcp://" + host + ":" + port;
    }
}
