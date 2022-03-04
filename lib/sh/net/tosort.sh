# Misc functions from my archives

    # These variables are used for testing internet connectivity
    # By default we use Google Public DNS
    testHost="8.8.8.8"
    testPort="53"
    
    # We use the following site to provide our ASN's
    asnSearch="https://bgpview.io/search/facebook"
    
    # Function to get a list of AS numbers
    get-as-numbers() {
      curl -s "${asnSearch}" | awk -F '[>&lt;]' '/bgpview.io\/asn/{print $5}'
    }
    
    # Function to pull ASN info from ripe.net
    get-asn-attr() {
      for asNum in "${@?No AS number supplied}"; do
        whois -H -h riswhois.ripe.net -- -F -K -i "${asNum}" | grep -Ev '^$|^%|::'
      done
    }
    
    # Function to test internet connectivity
    test-internet() {
      timeout 1 bash -c ">/dev/tcp/${testHost}/${testPort}" >/dev/null 2>&1
    }
    
    # Test whether we are online
    if test-internet; then
      # Build an array of ASN numbers, using formatting as at April 2018
      asnArray=( $(get-as-numbers) )
      # Read each returned line and feed it to iptables
      while read -r; do
        iptables -I INPUT 1 -s "${REPLY}" -j REJECT
        iptables -I OUTPUT 1 -s "${REPLY}" -j REJECT
      done &lt; &lt;(get-asn-attr "${asnArray[@]}" | awk '{print $2}')
      printf '%s\n' "'iptables' rules for blocking Facebook's IP ranges now added"
    fi

It doesn't work because it's redirecting.  If you set yourself up with a function that looks something like this:

    software::fetch() {
      local local_target remote_target
      remote_target="${1:?No target specified}"
      remote_target="$(curl "${remote_target}" -s -L -I -o /dev/null -w '%{url_effective}')"
      local_target="${remote_target##*/}"
      printf -- '%s\n' "Attempting to fetch ${remote_target}..."
      curl "${remote_target}" > "${local_target}" || return 1  
    }

In practice you'll get something that looks like this:

    ▓▒░$ software::fetch "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"
    Attempting to fetch https://definitionupdates.microsoft.com/download/DefinitionUpdates/VersionedSignatures/AM/1.329.689.0/amd64/mpam-fe.exe...
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                     Dload  Upload   Total   Spent    Left  Speed
    100  123M  100  123M    0     0  7432k      0  0:00:17  0:00:17 --:--:-- 7170k
