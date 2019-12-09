package main 

import data.tags_validation
import data.name_validation 

module_address[i] = address {
    changeset := input.resource_changes[i]
    address := changeset.address
}

tags_contain_minimum_set[i] = resources {
    changeset := input.resource_changes[i]
    tags := changeset.change.after.tags
    resources := [ 
        resource | 
        resource := module_address[i];
        not tags_validation.tags_contain_proper_keys(tags)
    ]
}

names_that_match_prefix[i] = resources {
    changeset := input.resource_changes[i]
    names := changeset.change.after.name
    resources := [
        resource | 
        resource := module_address[i];
        not data.name_validation.has_esdc_prefix(names)
    ]
}

resources_groups_have_proper_suffix[i] = resources { 
    changeset := input.resource_changes[i]
    resources := [
        resource | 
        resource := module_address[i];
        changeset.type == "azurerm_resource_group" 
        not data.name_validation.has_resource_group_suffix(changeset.change.after.name)
    ]
}

only_development_environments_allow[i] = resources { 
    changeset := input.resource_changes[i]
    resources := [
        resource | 
        resource := module_address[i];
        changeset.type == "azurerm_resource_group" 
        changeset.change.after.tags["Environment"] != "Development"
    ]
}

deny[msg] { 
    changeset := input.resource_changes[i]
    resources := [
        resource | 
        not re_match("^(canadaeast|canadacentral)$", changeset.change.after.location)
        resource := module_address[i]
    ]
    resources != []
    msg := sprintf("Invalid resource location only Canada is allowed: %v",[resources])
}

deny[msg] { 
    resources := only_development_environments_allow[_]
    resources != []
    msg := sprintf("Only development environments allowed: %v",[resources])
}

deny[msg] { 
    resources := resources_groups_have_proper_suffix[_] 
    resources != []
    msg := sprintf("Invalid resource group suffix for the following: %v",[resources])
}

deny[msg] {
    resources := tags_contain_minimum_set[_]
    resources != []
    msg := sprintf("Invalid tags (missing minimum required tags) for the following resources: %v", [resources])
}

deny[msg] { 
    resources := names_that_match_prefix[_]
    resources != []
    msg := sprintf("Invalid name Prefix (should be EsDC): %v", [resources])
}

