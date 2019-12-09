package main 

import data.tags_validation
import data.name_validation 
changeset[i] = changeset { 
    changeset := input.resource_changes[i]
}
module_address[i] = address {
    address := changeset[i].address
}

tags_contain_minimum_set[i] = resources {
    tags := changeset[i].change.after.tags
    resources := [ 
        resource | 
        resource := module_address[i];
        not tags_validation.tags_contain_proper_keys(tags)
    ]
}

names_with_invalid_prefix[i] = resources {
    names := changeset[i].change.after.name
    resources := [
        resource | 
        resource := module_address[i];
        not data.name_validation.has_esdc_prefix(names)
    ]
}

resource_groups_with_invalid_suffix[i] = resources {
    type := changeset[i].type
    resources := [
        resource | 
        resource := module_address[i];
        type == "azurerm_resource_group" 
        not data.name_validation.has_resource_group_suffix(changeset[i].change.after.name)
    ]
}

environments_other_than_development[i] = resources { 
    environment := changeset[i].change.after.tags["Environment"]
    resources := [
        resource | 
        resource := module_address[i];
        environment != "Development"
    ]
}

outside_canada = resources { 
    resources := [
        resource | 
        not re_match("^(canadaeast|canadacentral)$", changeset[i].change.after.location)
        resource := module_address[i]
    ]
}

deny[msg] { 
    resources := outside_canada[_]
    resources != []
    msg := sprintf("Invalid resource location only Canada is allowed: %v",[resources])
}

deny[msg] { 
    resources := environments_other_than_development[_]
    resources != []
    msg := sprintf("Only development environments allowed: %v",[resources])
}

deny[msg] { 
    resources := resource_groups_with_invalid_suffix[_] 
    resources != []
    msg := sprintf("Invalid resource group suffix for the following: %v",[resources])
}

deny[msg] {
    resources := tags_contain_minimum_set[_]
    resources != []
    msg := sprintf("Invalid tags (missing minimum required tags) for the following resources: %v", [resources])
}

deny[msg] {
    resources := names_with_invalid_prefix[_]
    resources != []
    msg := sprintf("Invalid name Prefix (should be EsDC): %v", [resources])
}

