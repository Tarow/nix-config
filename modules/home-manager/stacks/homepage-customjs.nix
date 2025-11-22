dozzleUri: ''
  (function () {
    console.log("[custom.js] Injecting Dozzle context menu with icons");

    const DOZZLE_BASE = "${dozzleUri}/show?name=";
    const DOZZLE_ICON = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/dozzle.png";

    // Create a reusable context menu element
    const menu = document.createElement("div");
    menu.style.position = "absolute";
    menu.style.background = "var(--theme-background, #fff)";
    menu.style.color = "var(--theme-foreground, #000)";
    menu.style.border = "1px solid var(--theme-border, #ccc)";
    menu.style.borderRadius = "4px";
    menu.style.boxShadow = "0 2px 8px rgba(0,0,0,0.2)";
    menu.style.padding = "4px 0";
    menu.style.zIndex = 9999;
    menu.style.display = "none";
    menu.style.minWidth = "160px";
    menu.style.fontSize = "14px";
    menu.style.fontFamily = "inherit";
    document.body.appendChild(menu);

    // Hide menu on click outside
    document.addEventListener("click", () => {
      menu.style.display = "none";
    });

    function createMenuItem(label, href, iconUrl) {
      const item = document.createElement("div");
      item.style.display = "flex";
      item.style.alignItems = "center";
      item.style.gap = "6px";
      item.style.padding = "6px 12px";
      item.style.cursor = "pointer";
      item.style.color = "inherit";
      item.style.background = "transparent";

      // Optional icon
      if (iconUrl) {
        const img = document.createElement("img");
        img.src = iconUrl;
        img.alt = label;
        img.width = 16;
        img.height = 16;
        img.style.width = "16px";
        img.style.height = "16px";
        img.style.objectFit = "contain";
        item.appendChild(img);
      }

      const span = document.createElement("span");
      span.textContent = label;
      item.appendChild(span);

      // Hover effect
      item.addEventListener("mouseenter", () => {
        item.style.background = "var(--theme-hover, rgba(0,0,0,0.05))";
      });
      item.addEventListener("mouseleave", () => {
        item.style.background = "transparent";
      });

      item.addEventListener("click", e => {
        e.stopPropagation();
        window.open(href, "_blank");
        menu.style.display = "none";
      });

      return item;
    }

    function showMenu(tile, x, y) {
      const id = tile.id || tile.getAttribute("data-name");
      if (!id) return;

      menu.innerHTML = "";

      // Add Dozzle Logs menu item (with icon)
      menu.appendChild(createMenuItem("View Dozzle Logs", DOZZLE_BASE + encodeURIComponent(id), DOZZLE_ICON));

      // Future external links can be added here:
      // menu.appendChild(createMenuItem("Another Link", "https://example.com", "https://example.com/icon.png"));

      menu.style.left = x + "px";
      menu.style.top = y + "px";
      menu.style.display = "block";
    }

    function attachContextMenus() {
      document.querySelectorAll("li.service").forEach(tile => {
        if (tile.dataset.contextMenuAttached) return;
        tile.dataset.contextMenuAttached = "true";

        tile.addEventListener("contextmenu", e => {
          e.preventDefault();
          showMenu(tile, e.pageX, e.pageY);
        });
      });
    }

    // Observe dynamic changes to service tiles
    const observer = new MutationObserver(() => attachContextMenus());
    observer.observe(document.body, { childList: true, subtree: true });

    // Initial attach
    attachContextMenus();
  })();
''
