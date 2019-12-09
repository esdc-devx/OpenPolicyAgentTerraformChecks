package name_validation


has_esdc_prefix(name) { 
    re_match("^EsDC[A-Za-z]*",name)
}

has_resource_group_suffix(name) { 
    re_match("[A-Za-z]*rg$",name)
}

