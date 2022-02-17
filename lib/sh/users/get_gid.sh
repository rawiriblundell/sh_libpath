

    func.PrintUser.GID() {
      if awk -F : '{print $0}' /etc/passwd | grep ^"${username}" 1&gt;/dev/null; then
        gid=$( grep ^"${username}" /etc/passwd | awk -F : '{print $4}' )
        printf "%s\n" "${gid}"
      else
        func.Erruser
      fi
    }
