package cn.blue16.aistudymate.controller;

import cn.blue16.aistudymate.common.api.ApiResponse;
import cn.blue16.aistudymate.dto.auth.LoginRequest;
import cn.blue16.aistudymate.dto.auth.LoginResponse;
import cn.blue16.aistudymate.dto.auth.UserDetailResponse;
import cn.blue16.aistudymate.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication endpoints for login, logout, token refresh, and user info.
 */
@RestController
@RequestMapping("/api/auth/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    /**
     * Log in with username and password.
     */
    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ApiResponse.success("Login successful", response);
    }

    /**
     * Register a new account.
     */
    @PostMapping("/register")
    public ApiResponse<LoginResponse> register(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ApiResponse.success("Registration successful", response);
    }

    /**
     * Refresh the current user's authentication details.
     */
    @PostMapping("/refresh")
    public ApiResponse<LoginResponse> refresh(HttpServletRequest request) {
        String currentUsername = (String) request.getAttribute("currentUsername");
        String currentUserId = (String) request.getAttribute("currentUserId");
        String currentUserRole = (String) request.getAttribute("currentUserRole");

        // Rebuild a response based on the current user details.
        UserDetailResponse userDetail = authService.getUserDetail(currentUsername);

        LoginResponse.UserInfo userInfo = new LoginResponse.UserInfo();
        userInfo.setUserId(userDetail.getUserId());
        userInfo.setUsername(userDetail.getUsername());
        userInfo.setRole(userDetail.getRole());
        userInfo.setStatus(userDetail.getStatus());
        userInfo.setPermissions(userDetail.getPermissions());
        userInfo.setManagedClasses(userDetail.getManagedClasses());

        LoginResponse response = new LoginResponse();
        response.setUserInfo(userInfo);

        return ApiResponse.success(response);
    }

    /**
     * Log out the current user.
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        return ApiResponse.success("Logout successful");
    }

    /**
     * Return the current user's profile information.
     */
    @GetMapping("/userinfo")
    public ApiResponse<UserDetailResponse> getUserInfo(HttpServletRequest request) {
        String currentUsername = (String) request.getAttribute("currentUsername");
        UserDetailResponse response = authService.getUserDetail(currentUsername);
        return ApiResponse.success(response);
    }
}
