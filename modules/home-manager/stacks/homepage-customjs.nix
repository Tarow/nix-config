dozzleUri: ''
  (function () {
    console.log(
      "[custom.js] Injecting Dozzle log buttons"
    );

    const DOZZLE_ICON =
      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/dozzle.png";
    const DOZZLE_BASE = "${dozzleUri}/show?name=";

    function inject(tile) {
      if (!tile) return;

      const id = tile.id;
      if (!id) return;

      const tags = tile.querySelector(".service-tags");
      if (!tags) return;

      // Prevent duplicates
      if (tags.querySelector(".custom-dozzle-button")) return;

      // Build Dozzle URL
      const url = DOZZLE_BASE + encodeURIComponent(id);

      // <a> wrapper
      const a = document.createElement("a");
      a.href = url;
      a.target = "_blank";
      a.rel = "noreferrer";
      a.className =
        "custom-dozzle-button flex items-center justify-center cursor-pointer service-tag";

      // Inner div with padding
      const wrap = document.createElement("div");
      wrap.className =
        "w-auto text-center overflow-hidden p-4 hover:bg-theme-500/10 dark:hover:bg-theme-900/20 rounded-b-[3px]";

      // Reduce horizontal padding on the side that touches the previous button
      wrap.style.paddingLeft = "2px";

      // Dozzle Icon
      const img = document.createElement("img");
      img.src = DOZZLE_ICON;
      img.loading = "lazy";
      img.alt = "Dozzle Logs";
      img.width = 16;
      img.height = 16;
      img.style.width = "16px";
      img.style.height = "16px";
      img.style.objectFit = "contain";

      wrap.appendChild(img);
      a.appendChild(wrap);

      tags.style.gap = "0px";
      tags.appendChild(a);
    }

    function scan() {
      document.querySelectorAll("li.service").forEach((tile) => inject(tile));
    }

    const observer = new MutationObserver(() => scan());
    observer.observe(document.body, { childList: true, subtree: true });
    scan();
  })();
''
