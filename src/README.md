
** CallStat ** (c) RoMiras 2008, Israel

CallStat is generating a statistics of calls to target groups (family, friends, work, ...) or single phone number.


#Supported formats

The list of file formats for databases, containing calls information:
 CSV (Comma Separated Values) text file


#Usage

  callstat <file.csv> 1 <Tel.#>
    Get call statistics for a phone number.

  callstat <file.csv> 2 <groups.txt>
    Get statistics by groups.


#Examples

Input .CSV file must contain following format of each row:
  dd/mm/yyyy,<destination>,h:mm:ss


#Developers

CallStat provides API for writing plugins. See sources for more information.
