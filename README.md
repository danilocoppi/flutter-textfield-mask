# Easy Mask

Easy way to apply inputMask to Flutter's TextFields.
Its used passing on widget creation passing on TextField's parameter inputFormatters.

The mask formatter cares about user's cursor position, to make fluid the user iteration.

# Usage

**Simple Sample**
`Import package:easy_mask/text_input_mask.dart`
Then instantiate `TextInputMask` passing at least a String `mask` parameter.

``` example
import package:easy_mask/text_input_mask.dart
...
  TextField(
    inputFormatters: [ TextInputMask(mask: '99? (99) 999 99-99') ],
  ),
  TextField(
    inputFormatters: [ TextInputMask(mask: '9+.99', reverse:true ) ],
  )
...
```

### Possible parameters

* **mask** is a String with the wanted mask pattern.
* **reverse** is a boolean that indicates if the user will type from right to left. Used normally on currency TextFields.
* **maxLength** is an Integer that limits the maximum size of returned masked text.  

### Mask Patterns Characters

 9 - is used to allow a number from 0-9
 A - is used to allow a letter from a-z or A-Z
 N - is used to allow a number or letter from 0-9, a-z or A-Z
 X - is used to allow any character

 Those tokens 9,A,N and X can be followed by one following modifier
? - indicates that is optional
\+ - indicates that must have at least 1 or more repetitions
\* - indicates that can have 0 or more repetitions
\ - is used as scape

Any other letters will be displayed on masking.

#### *Examples*

(card number) 999 999 999 999
(us cellphone) \\\+1 (999) 999 99 99
(currency) $ 9+,99
(version) 99?9?.99?9?.99?9?
(RG brazilian document) 99.999.999-N
