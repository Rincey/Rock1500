#
# https://projecteuler.net/
#

<#
1. Find the sum of all the multiples of 3 or 5 below 1000.
#>
$total = 0

foreach ($i in (1..999)) {
    if ((($i % 3) -eq 0) -or (($i % 5) -eq 0)) {
        $total += $i
    }
}
$total

<#
2. By considering the terms in the Fibonacci sequence whose values do not exceed four million, find the sum of the even-valued terms.
#>

$FnNext = 0
$Fn0 = 1
$Fn1 = 2
$total = 2
while ($FnNext -lt 4000000) {
    $FnNext = $Fn0 + $Fn1
    #write-host "$fnnext," -NoNewline
    if ($FnNext % 2 -eq 0) { $total += $FnNext }
    $Fn0 = $Fn1
    $fn1 = $FnNext
}
$total

<#
3. What is the largest prime factor of the number 600851475143
#>
$number = 600851475143
$MaxFactor = [math]::Sqrt($Number)

#take care of 2 as a factor
$Factor = 2
while ( ($Number % $Factor) -eq 0) {
    $Factor
    $Number = $Number / $Factor
}

#then brute force all odd numbers as factors up to max prime
#while $Number remains greater than max prime
$Factor = 3
while ($Factor -le $MaxFactor -and $number -ge $MaxFactor) {
    while ( ($Number % $Factor) -eq 0) {
        $Factor
        $Number = $Number / $Factor
    }
    $Factor += 2
}
$Number


<#
4. A palindromic number reads the same both ways. The largest palindrome made from the product of two 2-digit numbers is 9009 = 91 × 99.
Find the largest palindrome made from the product of two 3-digit numbers.
#>

# if brute force it, then it's going to be a number in the 000000s
# therefore start brute forcing with (316..999) (sqrt of 100000)

$highest = 0
$factors = ""
foreach ($i in (316..999)) {
    foreach ($j in (216..999)) {
        $product = $i * $j
        $productString = $product.tostring()

        if (($productString[0] -eq $productString[5]) -and 
($productString[1] -eq $productString[4]) -and
($productString[2] -eq $productString[3]) -and ($product -gt $highest)) {
            $highest = $product
            $factors = "$i x $j"
        }
    }
}
$highest
$factors

<#
5. 2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.

What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?
#>

$total = 1
$n = 10
foreach ($i in (1..$n)) {
    $total = $total * $i
}

$total = 2 * $total / $n
$total

#wrong!

<#
6. Find the difference between the sum of the squares of the first one hundred natural numbers and the square of the sum.
#>

$sumSquares = 0
$sum = 0
$n = 100
foreach ($i in (1..$n)) {
    $sumSquares = $sumSquares + ($i * $i)
    $sum += $i
}

$sumSquares, $($sum * $sum), $($($sum * $sum) - $sumSquares)

<#
7. By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see that the 6th prime is 13.
What is the 10 001st prime number?
#>

$ints = 0..1000000
for ($i = 2; $i -lt [Math]::Sqrt($ints.length); $i++) {
    if ($ints[$i] -eq 0) {
        continue
    }
    for ($j = $i * $i; $j -lt $ints.length; $j += $i) {
        $ints[$j] = 0
    }
}
#$ints | foreach { if ($_) { Write-Host -NoNewLine "$_ " } }
$a = $ints | ? { $_ -ne 0 }
$a[10001] # $a[0] = 1, not a prime. $a[1] = 2 the 1st prime

<#
9. There exists exactly one Pythagorean triplet for which a + b + c = 1000.
Find the product abc.
#>

# apparently, (2n+1)^2 + (2n^2+2n)^2 = (2n^2+2n+1)^2 for odd values of n
# also, let x = odd number.
# square it, half the square
for ($n = 1; $n -lt 21; $n += 1) {
    $a = (2 * $n) + 1
    $b = 2 * [math]::pow($n, 2) + 2 * $n
    $c = 2 * [math]::pow($n, 2) + 2 * $n + 1
    if ([math]::pow($a, 2) + [math]::pow($b, 2) -eq [math]::pow($c, 2)) {
        Write-Output "$($n): $a $b $c = $($a + $b + $c) "
    }

}

for ($n = 1; $n -lt 50; $n += 1) {
    if ($n % 2 -eq 0) {
        $a = $n
        $b = [math]::pow($n / 2, 2) - 1
        $c = [math]::pow($n / 2, 2) + 1
    }
    else {
        $a = $n
        $b = [math]::pow($n , 2) / 2 - 0.5
        $c = [math]::pow($n , 2) / 2 + 0.5
    }
    if ([math]::pow($a, 2) + [math]::pow($b, 2) -eq [math]::pow($c, 2)) {
        Write-Output "$($n): $a $b $c = $($a + $b + $c) "
    }

}
# this produces 8: 8 15 17 = 40
# theorem states if a,b,c is a triple then ka,kb,kc is also a triple
# so k = 25
# so solution is 25*8*25*15*25*17 = 31875000


<#
10. The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

Find the sum of all the primes below two million.
#>

$ints = 0..2000000
for ($i = 2; $i -lt [Math]::Sqrt($ints.length); $i++) {
    if ($ints[$i] -eq 0) {
        continue
    }
    for ($j = $i * $i; $j -lt $ints.length; $j += $i) {
        $ints[$j] = 0
    }
}
#$ints | foreach { if ($_) { Write-Host -NoNewLine "$_ " } }
$a = $ints | ? { $_ -ne 0 }
$a[10001] # $a[0] = 1, not a prime. $a[1] = 2 the 1st prime
($a | measure -sum  | select -exp sum) - 1

<#
14
The following iterative sequence is defined for the set of positive integers:

n → n/2 (n is even)
n → 3n + 1 (n is odd)

Using the rule above and starting with 13, we generate the following sequence:

13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1
It can be seen that this sequence (starting at 13 and finishing at 1) contains 10 terms. Although it has not been proved yet (Collatz Problem), it is thought that all starting numbers finish at 1.

Which starting number, under one million, produces the longest chain?

NOTE: Once the chain starts the terms are allowed to go above one million.
#>

foreach ($m in (1..1000000)) {
    $n = $m
    $i = 0

    while ($n -ne 1) {
        if ($n % 2 -eq 0) {
            $n = $n / 2

        }
        else {
            $n = 3 * $n + 1
        }
        $i ++
    }
    if ($i -gt 450) { Write-Output "$m $($i+1)" }

}
#837799

<#
28.
What is the sum of the numbers on the diagonals in a 1001 by 1001 spiral formed in the same way?


#>

$total = 0
$n = 3
while ($n -le 1001) {
    $subtotal = 4 * [math]::pow($n, 2) - 6 * $n + 6
    $total += $subtotal
    $n += 2
}
$total + 1

<# 
30 Find the sum of all the numbers that can be written as the sum of fifth powers of their digits.
#>

# max 6 digits
# [math]::pow(9,5)
# 59049
# 5*[math]::pow(9,5)
# 295245
#  6*[math]::pow(9,5)
# 354294

$grandtotal = 0
$powers = @{}
for ($i = 0; $i -lt 10; $i++) {
    $i
    $powers[$i] = [math]::pow($i, 5)
}

for ($i = 2; $i -lt 360000; $i++) {
    $total = 0
    $n = $i -split ''
    $n | ForEach-Object {
        if ($_ -ne "") {
            $total += $powers[[int]$_] 
        }
    }
    if ($total -eq $i) {
        $i
        $grandtotal += $i
    }
}
"-----"
$grandtotal

<#
13. get the first 10 digits of the sum of these numbers
#>

$numbers = gc .\euler13.txt
[bigint]$total = 0
foreach ($number in $numbers) {
    $total += [bigint]$number
}


<# 25 find the first 1000-digit Fibonacci number
#>




[bigint]$FnNext = 0
[bigint]$Fn1 = 1
[bigint]$Fn2 = 1
$FnIndex = 1
$Fnlength = 0
while ($Fnlength -lt 1000) {
    
    $Fnlength = $FnNext.ToString().Length
    #"$FnIndex $fn1"
    $FnIndex ++
    $FnNext = $Fn1 + $Fn2
    $Fn1 = $Fn2
    $fn2 = $FnNext
 
}
"$FnIndex $fn1"
#execution time: 155ms

<# 34.
145 is a curious number, as 1! + 4! + 5! = 1 + 24 + 120 = 145.

Find the sum of all numbers which are equal to the sum of the factorial of their digits.

Note: As 1! = 1 and 2! = 2 are not sums they are not included.#>




