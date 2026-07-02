package com.agilesolutions.service_b.controller;

import com.agilesolutions.common.domain.ServiceInfo;
import com.agilesolutions.service_b.service.InfoService;
import io.micrometer.observation.annotation.Observed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/service-b")
@RequiredArgsConstructor
@Slf4j
public class InfoController {

    private final InfoService infoService;

    @GetMapping("/info")
    @Observed(name = "getInfo", contextualName = "Get service info", lowCardinalityKeyValues = {"service", "service-b"})
    public ResponseEntity<ServiceInfo> getInfo() {

        log.info("Requesting information from Service B");

        return infoService.getInfo("default")
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
