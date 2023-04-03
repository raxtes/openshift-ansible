#!/bin/bash

# $ sh list_ssl_secrets.sh > ssl_secrets_iad.`date +%F`.txt

# some components have been customized from the original script which was provided as an 'example' for us to follow

#####################################
# https://access.redhat.com/solutions/3930291
# Some certs are not checked by openshift_certificate_expiry playbook like certs in kubeconfig and service serving certs

##
## print-all-cert-expire-date.sh  - OpenShift script to print all TLS cert expire date
##
## - This script is designed to run with root user as it reads files under /etc/origin directory
## - Do not use `openssl x509 -in` command which can only handle first cert in a given input
##

VERBOSE=false
if [ "$1" == "-v" ]; then
    VERBOSE=true
fi

function show_cert() {
  if [ "$VERBOSE" == "true" ]; then
    openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -text | egrep -A10 ^Cert
  else
    #openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -text | grep Validity -A3
    echo `openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -text | grep 'After :' -A1` \
    | sed 's/-- Not/\nNot/g;s/After :/After:/g;s/GMT/ /g;s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9] //g'
  fi
}

#####################################
## Process all cert files under /etc/origin/{master,node} directories
# These 'should' be covered in the easy-mode.yaml script?

#CERT_FILES=$(find /etc/origin/{master,node} -type f \( -name '*.crt' -o -name '*pem' \))
#for f in $CERT_FILES; do
#  echo "- $f"
#  cat $f | show_cert
#done

#====================================
# ANALYSIS
# this runs on whatever server you are running it on
# /etc/origin/{master,node} *.crt *.pem RECURSIVE
#====================================

#####################################
## Process all kubeconfig files under /etc/origin/{master,node} directories
# These 'should' be covered in the easy-mode.yaml script?

#KUBECONFIG_FILES=$(find /etc/origin/{master,node} -type f -name '*kubeconfig')
#for f in $KUBECONFIG_FILES; do
#  echo "- $f"
#  awk '/cert/ {print $2}' $f | base64 -d | show_cert
#done

#====================================
# ANALYSIS
# this runs on whatever server you are running it on
# /etc/origin/{master,node} *kubeconfig RECURSIVE
#====================================

#####################################
## Process all service serving cert secrets

#oc get service --no-headers --all-namespaces -o custom-columns='NAMESPACE:{metadata.namespace},NAME:{metadata.name},SERVING CERT:{metadata.annotations.service\.alpha\.openshift\.io/serving-cert-secret-name}' |
#while IFS= read line; do
#   items=( $line )
#   NAMESPACE=${items[0]}
#   SERVICE=${items[1]}
#   SECRET=${items[2]}
#   if [ $SECRET == "<none>" ]; then
#     continue
#   fi
#   echo "- secret/$SECRET -n $NAMESPACE"
#   oc get secret/$SECRET -n $NAMESPACE --template='{{index .data "tls.crt"}}'  | base64 -d | show_cert
#done

#====================================
# ANALYSIS
# These are all covered by the custom TLS secrets list below
#====================================

#####################################
## Process other custom TLS secrets, router, docker-registry, logging and metrics components

# these namespaces are missing from our cluster
#openshift-metrics-server metrics-server-certs ca.crt
#openshift-metrics-server metrics-server-certs tls.crt
#openshift-logging logging-elasticsearch admin-ca
#openshift-logging logging-elasticsearch admin-cert
#openshift-logging logging-curator ca
#openshift-logging logging-curator cert
#openshift-logging logging-fluentd ca
#openshift-logging logging-fluentd cert
#openshift-logging logging-fluentd ops-ca
#openshift-logging logging-fluentd ops-cert
#openshift-logging logging-kibana ca
#openshift-logging logging-kibana cert
#openshift-logging logging-kibana-proxy server-cert

# dont care about these?
#openshift-infra heapster-certs tls.crt (per Edward chat 23/03/28)

# The following are already included in easy-mode.yaml, but including here anyways so we dont miss them.
#default registry-certificates registry.crt
#default router-certs tls.crt

# added items to the list below based on our own list of openshift secrets

cat <<EOF |
default registry-certificates registry.crt
default router-certs tls.crt
default router-external-certs tls.crt
kube-service-catalog apiserver-ssl tls.crt
kube-service-catalog service-catalog-ssl tls.crt
openshift-ansible-service-broker asb-tls tls.crt
openshift-ansible-service-broker etcd-tls tls.crt
openshift-console console-serving-cert tls.crt
openshift-infra hawkular-cassandra-certs tls.client.truststore.crt
openshift-infra hawkular-cassandra-certs tls.crt
openshift-infra hawkular-cassandra-certs tls.peer.truststore.crt
openshift-infra hawkular-metrics-certs ca.crt
openshift-infra hawkular-metrics-certs tls.crt
openshift-infra hawkular-metrics-certs tls.truststore.crt
openshift-monitoring alertmanager-main-tls tls.crt
openshift-monitoring grafana-tls tls.crt
openshift-monitoring kube-state-metrics-tls tls.crt
openshift-monitoring node-exporter-tls tls.crt
openshift-monitoring prometheus-k8s-tls tls.crt
openshift-template-service-broker apiserver-serving-cert tls.crt
openshift-web-console webconsole-serving-cert tls.crt
EOF
while IFS= read line; do
  items=( $line )
  NAMESPACE=${items[0]}
  SECRET=${items[1]}
  FIELD=${items[2]}
  echo -e "\n##########\nNAMESPACE:  $NAMESPACE \n   SECRET:  $SECRET \n    FIELD:  .data.$FIELD\n"
  oc get secret/$SECRET -n $NAMESPACE --template="{{index .data \"$FIELD\"}}"  | base64 -d | show_cert
done

#====================================
# ANALYSIS
# check listed oc secrets for specific certs
#====================================


#####################################
## Process all cert files under /etc/origin/node directories --> Each node
# this requires root passwordless to nodes...  no thanks
# These 'should' be covered in the easy-mode.yaml script?

### The following sections
### Script execution machine require password-less SSH access to all nodes
#echo "------------------------- all nodes' kubelet TLS certificate -------------------------"
#for node in `oc get nodes |awk 'NR>1'|awk '{print $1}'`; do
#  for f in `ssh $node "find /etc/origin/node -type f \( -name '*.crt' -o -name '*pem' \)"`; do
#    echo "$node - $f"
#    ssh $node cat $f | show_cert
#  done
#done

#====================================
# ANALYSIS
# ssh into ALL nodes
# /etc/origin/node *.crt *.pem RECURSIVE
#====================================


