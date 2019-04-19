#!/usr/bin/env nft -f
flush ruleset

table ip Inet4 { {{range $index, $element := .knocks}}
    set Knocked_{{$index}} {
        type ipv4_addr
        flags timeout
        timeout {{.timeout}}s
        gc-interval 5s
    } {{end}}

    {{range $index, $element := .knocks}}
    chain Knock_{{$index}} {
        {{if ne $index 0 -}}set update ip saddr timeout 1s @Knocked_{{add $index -1}} {{end}}
        set add ip saddr @Knocked_{{$index}}
    } {{end}}
        
    chain PortKnock_{{.target.port}}_{{.target.protocol}} {
        {{.target.protocol}} dport {{.target.port}} ct state new ip saddr @Knocked_{{ add (len .knocks) -1}} accept
        {{- range $index, $element := .knocks -}}
        {{$rev_index := sub (len $.knocks) $index 1}}
        {{(index $.knocks $rev_index).protocol}} dport {{(index $.knocks $rev_index).port}} ct state new {{if ne $rev_index 0}}ip saddr @Knocked_{{sub $rev_index 1}}{{end}} goto Knock_{{$rev_index}}
        {{- end}}
    }

    chain input {
        type filter hook input priority 0
        policy accept
    
        # allow established/related connections
        ct state established,related accept
    
        # port-knocking
        jump PortKnock_{{.target.port}}_{{.target.protocol}}
        {{.target.protocol}} dport {{.target.port}} ct state new drop
    }
}


