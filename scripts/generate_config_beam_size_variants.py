import yaml

def get_config_beam_size_variants(config_file):
    # load the .yaml file to be changed
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)

    # create new versions of the config file with different beam sizes
    for beam_size in range(2, 21, 2):
        # change the beam_size in the config file
        config['testing']['beam_size'] = beam_size

        # save to a new config file
        with open(f'configs/bpe_level_model_4000_beam_size/beam_size_{beam_size}.yaml', 'w') as out_file:
            yaml.dump(config, out_file)

if __name__ == '__main__':
    get_config_beam_size_variants('configs/bpe_level_model_4000.yaml')