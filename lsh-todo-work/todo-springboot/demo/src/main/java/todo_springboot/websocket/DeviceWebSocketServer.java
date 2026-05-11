package todo_springboot.websocket;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

@Slf4j
@Component
@ServerEndpoint("/ws/device")
public class DeviceWebSocketServer {

    private static final Set<Session> SESSIONS = new CopyOnWriteArraySet<>();

    @OnOpen
    public void onOpen(Session session) {
        SESSIONS.add(session);
        log.info("WebSocket connected: {}, online: {}", session.getId(), SESSIONS.size());
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        log.info("WebSocket message from {}: {}", session.getId(), message);
    }

    @OnClose
    public void onClose(Session session) {
        SESSIONS.remove(session);
        log.info("WebSocket disconnected: {}, online: {}", session.getId(), SESSIONS.size());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        if (session != null) {
            SESSIONS.remove(session);
        }
        log.warn("WebSocket error: {}", session == null ? "unknown" : session.getId(), throwable);
    }

    public static void broadcast(String message) {
        for (Session session : SESSIONS) {
            if (!session.isOpen()) {
                SESSIONS.remove(session);
                continue;
            }
            try {
                session.getBasicRemote().sendText(message);
            } catch (IOException ex) {
                SESSIONS.remove(session);
                log.warn("WebSocket send failed: {}", session.getId(), ex);
            }
        }
    }
}
