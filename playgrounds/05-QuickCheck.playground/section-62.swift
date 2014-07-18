check("qsort should behave like sort", { (x: [Int]) in return qsort(x) == x.sorted(<) })
