describe('Config', function(){
  it('new Config', function(){
    var conf = new Config();
    expect(true).toBe(conf instanceof Config);
  });
  it('config.load', function(){
    var conf = new Config();
    conf.load('../../public/sample.json');
  });
});