package tags_validation

minimum_tags = {
    "Branch",
    "Classification",
    "Project",
    "Directorate",
    "Environment",
    "ServiceOwner"
    }


tags_contain_proper_keys(tags) {
    keys := {key | tags[key]}
    leftover := minimum_tags - keys
    leftover == set()
}