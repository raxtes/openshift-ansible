# 2023/04 Melissa England RARE-1033
#
# Summarize JSON results from easy-mode openshift script.
# Set REPORT to the output file from easy-mode.
#
# Example usage:
#
# Export Method
# export REPORT=cert-expiry-report.20230411T003734.json
# sh ssl_summary.sh > myoutput.txt
#
# Inline Method
# REPORT=cert-expiry-report.20230411T003734.json sh ssl_summary.sh > myoutput.txt

if [[ -z "$REPORT" ]]; then
    echo -e "\nSet var before running script:\n\nexport REPORT=filename\n" 1>&2
    exit 1
fi


echo "##################################################################"
echo "REPORT: $REPORT"
echo "##################################################################"
echo "SUMMARY"
cat $REPORT | jq '.summary'
echo "##################################################################"
echo "COUNT - unique"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | {cert_cn,issuer,path,expiry}' -c | sort | uniq | wc -l
echo "##################################################################"
echo "COUNT - not unique"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | {cert_cn,issuer,path,expiry}' -c | wc -l
echo "##################################################################"
echo "EXPIRED CERTS"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.health | test("expired"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
echo "##################################################################"
echo "EXPIRING CERTS"
export EXPIRY=`date --date='+0 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+1 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+2 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+3 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+4 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+5 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+6 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+7 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+8 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+9 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+10 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+11 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
export EXPIRY=`date --date='+12 months' '+%Y-%m'`; cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | (select (.expiry | test("'$EXPIRY'"))) | {expiry,cert_cn,issuer,path}' -c | sort | uniq | jq -c
echo "##################################################################"
echo "EXPIRATION DATES"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | .expiry' -r | awk '{print $1}' | sort | uniq -c
echo "##################################################################"
echo "CERT PATHS"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | .path' -r | sort | uniq -c
echo "##################################################################"
echo "CERT CN NAMES"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | .cert_cn' -r | sort | uniq -c
echo "##################################################################"
echo "CERT ISSUER NAMES"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | .issuer' -r | sort | uniq -c
echo "##################################################################"
echo "LIST ALL CERTS - unique"
cat $REPORT | jq '.[][] | .etcd[],.kubeconfigs[],.ocp_certs[],.registry[],.router[],.secrets[],.routes[] | {cert_cn,issuer,path,expiry}' -c | sort | uniq | jq -c
echo "##################################################################"
echo "SECTION NAMES"
cat $REPORT | jq '.data[] | keys' | jq '.[]' -r | sort | uniq -c
echo "##################################################################"
echo "NODES"
cat $REPORT | jq '.data | keys' | jq '.[]' -r
echo "##################################################################"
