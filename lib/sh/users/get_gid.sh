

get_gid() {
  if awk -F : '{print $0}' /etc/passwd | grep ^"${username}" >/dev/null 2>&1; then
    gid=$(grep ^"${username}" /etc/passwd | awk -F : '{print $4}' )
    printf "%s\n" "${gid}"
  else
    func.Erruser
  fi
}
