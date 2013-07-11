# Calculates Prime Factors of Given Integer
#
# Algorithm based on an article from "Practical Computing", February 1980 (when computer magazines were really about computing:-)
#
# This is a standard sieve, but rather than trying all increasing integers as divisors the next possible divisor is
# calculated by adding an increment from a (repeating) sequence - thereby missing any even numbers or any multiples of 3 or 5.
#
# The initial divisor is 2.  The increment list repeats from the forth entry, so the possible divisors will start with:
#
# Divisor:   2, 3, 5, 7,   11, 13, 17, 19, 23, 29, 31, 37,           41, 43, 47, 49, 53, 59, 61, 67,           71, 73, 77, 79, 83, 89, 91, 97
# Increment:  +1 +2 +2   +4  +2  +4  +2  +4  +6  +2  +6   [repeat] +4  +2  +4  +2  +4  +6  +2  +6   [repeat] +4  +2  +4  +2  +4  +6  +2  +6 
#
# This approach skips a large number of trial division operations at the expense of some array (list) management.
#
# PowerShell version, Chris Warwick, 2006
# Last modified September 2012
# .
# Source: http://chrisjwarwick.wordpress.com/2012/09/16/finding-prime-factors/

Param ($n=$(Throw "Specify a number to factorise"))

$DivisorIncrements=1,2,2,4,2,4,2,4,6,2,6
$IncrementLength=$DivisorIncrements.Length

$Root=[Math]::Pow($n,0.5)    # All factors found once divisor is greater than number's square-root

$Divisor=2        # Initial divisor - try this as first factor
$Number=$n        # Save original number
$Answer=""        # Resultant list of factors appended to this string
$i=0            # Index into increment list

Write-Verbose ("Finding factors of $n (with root ~{0:0.##})" -f $Root)

For (;;) {
   Write-Verbose "Trying $Divisor"
   $Remainder=$n/$Divisor
   If ($Remainder -eq [Math]::Truncate($Remainder)) {
      # Remainder is a whole number, found a factor...
      Write-Verbose "Found factor $Divisor"
      If ($Remainder -eq 1) {
         # All factors have been found
         Write-Verbose "Remainder is 1, all factors found"
         Break
      }
      $n=$Remainder        # ...remove this factor and calculate factors of remainder
      $Root=[Math]::Pow($n,0.5)        # ...new end-point
      Write-Verbose ("Remainder is now $Remainder (root ~{0:0.##}), finding factors of this..." -f $Root)
      $Answer+=" $Divisor x"    # ... save list of factors for display
   }
   Else {
      # Current divisor was not a factor
      Write-Verbose "$Divisor is not a factor"
      $Divisor+=$DivisorIncrements[$i]        # Add to the divisor, skipping multiples of 2, 3, 4, 5
      Write-Verbose "Adding $($DivisorIncrements[$i]); divisor is now $Divisor"
      $i++        # Next time add the next increment from the list
      If ($i -ge $IncrementLength) {
         # Got to end of increments list...
         $i=3        # List repeats from the 4th element
         If ($Divisor -gt $Root) {
            # Check at this point that the divisor isn't too large
            Write-Verbose "Divisor now greater than Sqrt of remainder... done"
            Break
         }
      }
   }
}

If ($n -eq $Number) {"$n is Prime"}
Else {
   "$Number =$Answer $n"   # Append last remainder and display list of factors
}

