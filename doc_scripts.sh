headerdoc2html -j -o mMultiContacts/Documentation mMultiContacts/mMultiContacts.h     
headerdoc2html -j -o mMultiContacts/Documentation mMultiContacts/mAddressDetails.h     
headerdoc2html -j -o mMultiContacts/Documentation mMultiContacts/mContacts.h     
headerdoc2html -j -o mMultiContacts/Documentation mMultiContacts/mCategories.h     
headerdoc2html -j -o mMultiContacts/Documentation mMultiContacts/mDetails.h     

gatherheaderdoc mMultiContacts/Documentation


sed -i.bak 's/<html><body>//g' mMultiContacts/Documentation/masterTOC.html
sed -i.bak 's|<\/body><\/html>||g' mMultiContacts/Documentation/masterTOC.html
sed -i.bak 's|<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">||g' mMultiContacts/Documentation/masterTOC.html