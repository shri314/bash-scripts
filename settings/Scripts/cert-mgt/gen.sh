#!/bin/bash

set -euo pipefail

blue() {
   echo -ne "\e[1;34m"; echo -n "$@"; echo -e "\e[0m"
}

yellow() {
   echo -ne "\e[1;33m"; echo -n "$@"; echo -e "\e[0m"
}

\which openssl 1>/dev/null || { echo "openssl command required" && exit 1; }
\which keytool 1>/dev/null || { echo "keytool command required" && exit 1; }

openssl_()
{
   ( set -x ; openssl "$@" )
}

keytool_()
{
   ( set -x ; keytool "$@" )
}

blue "==================================================="
echo -n "Enter CA: "
read CA_NAME
blue "==================================================="

if [ ! -d "ca/$CA_NAME" ]
then
   rm -rf "ca/$CA_NAME.tmp"
   mkdir -p "ca/$CA_NAME.tmp"
   (
      set -euo pipefail
      cd "ca/$CA_NAME.tmp"

      yellow "---------------------------------------------------"
      echo " Generating key-pair..."
      yellow "---------------------------------------------------"

      [ "${CA_BITS="4096"}"    == "4096"        ] && echo Using default for CA_BITS
      [ "${CA_DAYS="3650"}"    == "3650"        ] && echo Using default for CA_DAYS
      [ "${CA_KEY_PASS="ca12345"}" == "ca12345" ] && echo Using default for CA_KEY_PASS
      [ "${CA_SUBJECT_ALT_NAMES=""}" == ""      ] && echo Using default for CA_SUBJECT_ALT_NAMES

      [ "${CA_SUBJECT_ALT_NAMES}"    != "" ] && export CA_SUBJECT_ALT_NAMES="DNS:$CA_NAME,$CA_SUBJECT_ALT_NAMES"
      [ "${CA_SUBJECT_ALT_NAMES}"    == "" ] && export CA_SUBJECT_ALT_NAMES="DNS:$CA_NAME"

      echo "$CA_KEY_PASS" > "$CA_NAME.key.pass"

      openssl_ \
         genrsa \
         $(if [ ! -z "$CA_KEY_PASS" ]; then echo -des3; fi) \
         -out "$CA_NAME.key" \
         $(if [ ! -z "$CA_KEY_PASS" ]; then echo -passout "file:$CA_NAME.key.pass"; fi) \
         $CA_BITS

      cat > "$CA_NAME.cnf" <<-EOF
[req]
default_bits = $CA_BITS
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=California
O=FogHorn Systems
CN = $CA_NAME

[ req_ext ]
subjectAltName = ${CA_SUBJECT_ALT_NAMES}
EOF

      yellow "---------------------------------------------------"
      cat "$CA_NAME.cnf"
      yellow "---------------------------------------------------"

      yellow "---------------------------------------------------"
      echo " Generating self-signed cert..."
      yellow "---------------------------------------------------"

      openssl_ \
         req \
         -x509 \
         -new \
         -nodes \
         -key "$CA_NAME.key" \
         -passin "file:$CA_NAME.key.pass" \
         -sha256 \
         -days "$CA_DAYS" \
         -out "$CA_NAME.crt" \
         -config "$CA_NAME.cnf" \
         -extensions req_ext
   )

   mv "ca/$CA_NAME.tmp" "ca/$CA_NAME"
fi

echo
blue "==================================================="
echo -n "Enter Domain: "
read DOM_NAME
blue "==================================================="

if [ ! -d "domain/$DOM_NAME" ]
then
   rm -rf "domain/$DOM_NAME.tmp"
   mkdir -p "domain/$DOM_NAME.tmp"
   (
      set -euo pipefail
      cd "domain/$DOM_NAME.tmp"

      yellow "---------------------------------------------------"
      echo " Generating key-pair..."
      yellow "---------------------------------------------------"

      [ "${DOM_BITS="4096"}"    == "4096"                   ] && echo Using default for DOM_BITS
      [ "${DOM_DAYS="3650"}"    == "3650"                   ] && echo Using default for DOM_DAYS
      [ "${DOM_KEY_PASS="dom12345"}" == "dom12345"          ] && echo Using default for DOM_KEY_PASS
      [ "${DOM_KEYSTORE_PASS="xdom12345"}" == "xdom12345"   ] && echo Using default for DOM_KEYSTORE_PASS
      [ "${DOM_TRUSTSTORE_PASS="ydom12345"}" == "ydom12345" ] && echo Using default for DOM_TRUSTSTORE_PASS
      [ "${DOM_SUBJECT_ALT_NAMES=""}" == ""                 ] && echo Using default for DOM_SUBJECT_ALT_NAMES

      [ "${DOM_SUBJECT_ALT_NAMES}"    != "" ] && export DOM_SUBJECT_ALT_NAMES="DNS:$DOM_NAME,$DOM_SUBJECT_ALT_NAMES"
      [ "${DOM_SUBJECT_ALT_NAMES}"    == "" ] && export DOM_SUBJECT_ALT_NAMES="DNS:$DOM_NAME"

      echo "$DOM_KEY_PASS" > "$DOM_NAME.key.pass"
      echo "$DOM_KEYSTORE_PASS" > "$DOM_NAME.keystore.pass"
      echo "$DOM_TRUSTSTORE_PASS" > "$DOM_NAME.truststore.pass"

      openssl_ \
         genrsa \
         $(if [ ! -z "$DOM_KEY_PASS" ]; then echo -des3; fi) \
         -out "$DOM_NAME.key" \
         $(if [ ! -z "$DOM_KEY_PASS" ]; then echo -passout "file:$DOM_NAME.key.pass"; fi) \
         $DOM_BITS

      yellow "---------------------------------------------------"
      echo " Generating signing request..."
      yellow "---------------------------------------------------"

      cat > "$DOM_NAME.cnf" <<-EOF
[req]
default_bits = $DOM_BITS
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=California
O=FogHorn Systems
CN = $DOM_NAME

[ req_ext ]
subjectAltName = ${DOM_SUBJECT_ALT_NAMES}
EOF

      yellow "---------------------------------------------------"
      cat "$DOM_NAME.cnf"
      yellow "---------------------------------------------------"

      openssl_ \
         req \
         -new \
         -sha256 \
         -key "$DOM_NAME.key" \
         -passin "file:$DOM_NAME.key.pass" \
         -out "$DOM_NAME.csr" \
         -config "$DOM_NAME.cnf" \
         -extensions req_ext

      yellow "---------------------------------------------------"
      echo " Generating ca-signed cert..."
      yellow "---------------------------------------------------"

      openssl_ \
         x509 \
         -req \
         -in "$DOM_NAME.csr" \
         -CA "../../ca/$CA_NAME/$CA_NAME.crt" \
         -CAkey "../../ca/$CA_NAME/$CA_NAME.key" \
         -passin "file:../../ca/$CA_NAME/$CA_NAME.key.pass" \
         -CAcreateserial \
         -out "$DOM_NAME.crt" \
         -days "$DOM_DAYS" \
         -sha256 \
         -extfile "$DOM_NAME.cnf" \
         -extensions req_ext

      yellow "---------------------------------------------------"
      echo " Generating keystore in pkcs..."
      yellow "---------------------------------------------------"

      openssl_ \
         pkcs12 \
         -export \
         -inkey "$DOM_NAME.key" \
         -passin "file:$DOM_NAME.key.pass" \
         -in "$DOM_NAME.crt" \
         -name "$DOM_NAME" \
         -out "$DOM_NAME.keystore.p12" \
         -passout "file:$DOM_NAME.keystore.pass"

      yellow "---------------------------------------------------"
      echo " Generating truststore in pkcs..."
      yellow "---------------------------------------------------"

      #openssl_ \
      #   pkcs12 \
      #   -export \
      #   -nokeys \
      #   -in "../../ca/$CA_NAME/$CA_NAME.crt" \
      #   -caname "$CA_NAME" \
      #   -out "$DOM_NAME.truststore.p12" \
      #   -passout "file:$DOM_NAME.truststore.pass"

      keytool_ \
         -import \
         -noprompt \
         -trustcacerts \
         -storetype pkcs12 \
         -storepass "$DOM_TRUSTSTORE_PASS" \
         -alias "$CA_NAME" \
         -file "../../ca/$CA_NAME/$CA_NAME.crt" \
         -keystore "$DOM_NAME.truststore.p12"

      test -f "$DOM_NAME.truststore.p12"
      cat "../../ca/$CA_NAME/$CA_NAME.crt" > "$DOM_NAME.ca-bundle"
   )

   mv "domain/$DOM_NAME.tmp" "domain/$DOM_NAME"
fi

echo
blue "==================================================="
echo "ca/$CA_NAME":
openssl x509 -in "ca/$CA_NAME/$CA_NAME.crt" -noout -startdate -enddate -subject -issuer | cat -n
echo "domain/$DOM_NAME":
openssl x509 -in "domain/$DOM_NAME/$DOM_NAME.crt" -noout -startdate -enddate -subject -issuer | cat -n
blue "==================================================="
