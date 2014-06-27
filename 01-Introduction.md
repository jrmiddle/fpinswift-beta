## Introduction

Why write this book? There is plenty of documentation on Swift readily
available from Apple, and there are many more books on the way. Why does the
world need yet another book on yet another programming language?

This books tries to teach you to think *functionally*. We believe that
Swift has the proper language features to teach you how to write
*functional programs*. But what makes a program functional? Or why
bother learning about this in the first place? In his paper, "Why
Functional Programming Matters," John Hughes writes:

> Functional programming is so called because its fundamental
> operation is the application of functions to arguments. A main
> program itself is written as a function that receives the program’s
> input as its argument and delivers the program’s output as its
> result.

So rather than thinking of a program as a sequence of assignments and
method calls, functional programmers emphasize that each program can
be repeatedly broken into smaller and smaller pieces. By avoiding
assignment statements and side effects, Hughes argues that functional
programs are more modular than their imperative- or object-oriented
counterparts. And modular code is a Very Good Thing.

In our experience, learning to think functionally is not an easy
thing. It challenges the way we've been trained to decompose
problems. For programmers who are used to writing for-loops, recursion can be
confusing; the lack of assignment statements and global state is
crippling; and closures, generics, higher-order functions, and monads are
just plain weird.

In this book, we want to demystify functional programming and dispel
some of the prejudices people may have against it. You don't need to
have a PhD in mathematics to use these ideas to improve your code!  We
won't cover the complete Swift language specification or teach you to
set up your first project in Xcode. But we will try to teach you the
basic principles of pure functional programming that will make you a
better developer in any language.
