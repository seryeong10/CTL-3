package com.baeumpay.backend.setting.dto;

import jakarta.validation.constraints.NotNull;

public record UserSettingUpdateRequest(

        @NotNull
        Boolean notificationEnabled,

        @NotNull
        Boolean largeTextEnabled

) {
}