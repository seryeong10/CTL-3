package com.baeumpay.backend.setting.dto;

import com.baeumpay.backend.setting.entity.UserSetting;

import java.time.LocalDateTime;

public record UserSettingResponse(
        Long settingId,
        Long userId,
        Boolean notificationEnabled,
        Boolean largeTextEnabled,
        LocalDateTime updatedAt
) {

    public static UserSettingResponse from(
            UserSetting setting
    ) {

        return new UserSettingResponse(
                setting.getSettingId(),
                setting.getUserId(),
                setting.getNotificationEnabled(),
                setting.getLargeTextEnabled(),
                setting.getUpdatedAt()
        );
    }
}