/* Variables */
let isPlayerDataLoaded = false;
let isMoving = false;

window.addEventListener('message', event => {
  const data = event.data;

  switch (data.action) {
    case 'playerData':
      if (data.id) {
        $('.id').text('ID:' + " " + data.id);
      }
      if (data.cash) {
        $('.cash').text('Cash:' + " " + '£' + data.cash);
      }
      if (data.bank) {
        $('.bank').text('Bank:' + " " + '£' + data.bank);
      }
      if (data.job) {
        $('.job').text(data.job);
      }
      if (data.gang) {
        $('.gang').text(data.gang);
      }
      isPlayerDataLoaded = true
      break;
    case 'jobChange':
      if (data.job) {
        $('.job').text(data.job).css('animation', `fade-change 2s ease-in-out`);
        setTimeout(() => {
          $('.job').css('animation', '');
        }, 2000);
      }
      break;
    case 'gangChange':
      if (data.gang) {
        $('.gang').text(data.gang).css('animation', `fade-change 2s ease-in-out`);
        setTimeout(() => {
          $('.gang').css('animation', '');
        }, 2000);
      }
      break;
      case 'moneyChange':
        if (data.account === 'cash') {
          $('.cash').text('£' + data.amount).css('animation', `fade-change 2s ease-in-out`);
          setTimeout(() => {
            $('.cash').css('animation', '');
          }, 2000);
        }
        if (data.account === 'bank') {
          $('.bank').text('£' + data.amount).css('animation', `fade-change 2s ease-in-out`);
          setTimeout(() => {
            $('.bank').css('animation', '');
          }, 2000);
        }
  }
});
/* Functions */
function loadSavedState() {
  const savedPosition = localStorage.getItem('hudPosition');
  if (savedPosition) {
    const { left, top } = JSON.parse(savedPosition);
    $('.huditems').css({
      left: left + 'px',
      top: top + 'px'
    });
    hudPosition = { x: left, y: top };
  }

  const savedVisibility = localStorage.getItem('hudVisible');
  if (savedVisibility === 'true') {
    $('.huditems').show();
    $.post(`https://${GetParentResourceName()}/setDisplayState`, JSON.stringify({ displayState: true }));
  } else {
    $('.huditems').hide();
    $.post(`https://${GetParentResourceName()}/setDisplayState`, JSON.stringify({ displayState: false }));
  }
  }


function loadItemVisibility() {
  const itemVisibility = JSON.parse(localStorage.getItem('itemVisibility')) || {};
  $('.setting-item input[type="checkbox"]').each(function () {
    const item = $(this).data('item');
    if (itemVisibility.hasOwnProperty(item)) {
      const isVisible = itemVisibility[item];
      $(this).prop('checked', isVisible);
      const $statusItem = $(`.${item}`).closest('.status-item');
      if (isVisible) {
        $statusItem.fadeIn(300);
      } else {
        $statusItem.hide();
      }
    } else {
      $(this).prop('checked', true);
      $(`.${item}`).closest('.status-item').fadeIn(300);
    }
  });
}

  const checkPlayerDataInterval = setInterval(function () {
    if (isPlayerDataLoaded) {
      clearInterval(checkPlayerDataInterval);
      loadItemVisibility();
      loadSavedState();
      $('.setting-item input[type="checkbox"]').on('change', updateItemVisibility);
    }
  }, 100);