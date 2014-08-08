func composeFilters(filter1: Filter, filter2: Filter) -> Filter {
    return {img in filter1(filter2(img)) }
}