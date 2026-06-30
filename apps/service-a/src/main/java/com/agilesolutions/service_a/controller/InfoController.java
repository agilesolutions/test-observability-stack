package com.agilesolutions.service_a.controller;

import com.agilesolutions.common.domain.ServiceInfo;
import com.agilesolutions.service_a.service.InfoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/service-a")
@RequiredArgsConstructor
@Tag(name = "InfoController", description = "API to request for service information")
public class InfoController {

    private final InfoService infoService;

    @GetMapping(value = "/info")
    @Operation(summary = "request info from service B", description = "Access information from Service B")
    @ApiResponses(value = {
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Information retrieved"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Not existing"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "500", description = "Internal Server error")
    })
    public ResponseEntity<ServiceInfo> getRemoteInfo() {

        ServiceInfo info = infoService.getExternalInfo();
        return ResponseEntity.ok(info);
    }


}
