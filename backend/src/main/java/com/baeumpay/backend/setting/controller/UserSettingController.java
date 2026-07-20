package com.baeumpay.backend.setting.controller;

import com.baeumpay.backend.setting.dto.UserSettingResponse;
import com.baeumpay.backend.setting.dto.UserSettingUpdateRequest;
import com.baeumpay.backend.setting.service.UserSettingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/settings")
public class UserSettingController {

    private final UserSettingService userSettingService;

    @GetMapping("/{userId}")
    public UserSettingResponse getSetting(
            @PathVariable Long userId
    ) {

        return userSettingService
                .getSetting(userId);
    }

    @PutMapping("/{userId}")
    public UserSettingResponse updateSetting(
            @PathVariable Long userId,
            @Valid @RequestBody UserSettingUpdateRequest request
    ) {

        return userSettingService.updateSetting(
                userId,
                request
        );
    }
}