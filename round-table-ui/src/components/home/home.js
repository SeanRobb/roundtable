import React, {useState} from 'react';
import PropTypes from 'prop-types';
import styles from './home.module.css';
import { Paper, Container, Typography, Grid, Button, FormControl,Input,InputLabel } from '@material-ui/core';
import { useHistory } from "react-router-dom";
import CreateGameButton from '../createGameButton/createGameButton';
import {clearUsername} from '../../utils/index';


const Home = () => {
const history = useHistory();
const [game,setGame] = useState();

return (
  <Container className={styles.home} data-testid="home">
    <Paper elevation={1} style={{padding:'20px'}}>
      <Grid container direction="column" alignItems="center" justify="center">
        <Grid item xs={12}>
          <Typography variant='h2'>Welcome to Round Table Games</Typography>
        </Grid>
        <Grid item>
          <Grid container spacing={3} justify='center' alignItems='stretch'>
            <Grid item>
              <Paper elevation={2} style={{padding:'20px'}}>
                <Grid container  direction="column" alignItems="center" justify="center">
                  <Grid item>
                    <Typography variant='h6'>Werewolf</Typography>
                  </Grid>
                  <Grid item>
                    <CreateGameButton type="Werewolf" />
                  </Grid>
                </Grid>
              </Paper>
            </Grid>
            <Grid item>
              <Paper elevation={2} style={{padding:'20px'}}>
                <Grid container  direction="column" alignItems="center" justify="center">
                  <Grid item>
                    <Typography variant='h6'>Next Round</Typography>
                  </Grid>
                  <Grid item>
                    <CreateGameButton type="Next Round" />
                  </Grid>
                </Grid>
              </Paper>
            </Grid>
            <Grid item>
              <Paper elevation={2}  style={{padding:'20px'}}>
              <Grid container  direction="column" alignItems="center" justify="center">
                  <Grid item>
                    <Typography variant='h6'>Register for existing game</Typography>
                  </Grid>
                  <Grid item>
                    <Button color="primary" onClick={()=>{
                        history.push('/register')
                      }}>Register</Button>
                  </Grid>
                </Grid>
              </Paper>
            </Grid>
            <Grid item>
              <Paper elevation={2}  style={{padding:'20px'}}>
              <Grid container  direction="column" alignItems="center" justify="center">
                  <Grid item>
                    <Typography variant='h6'>View existing game</Typography>
                  </Grid>
                  <Grid item>
                  <FormControl fullWidth={true}>
                    <InputLabel htmlFor="gameInput">Name:</InputLabel>
                      <Input id="gameInput" type="text" value={game} onChange={(event) =>{
                        setGame(event.target.value)
                      }}  name="game" />
                  </FormControl>
                    <Button color="primary" onClick={()=>{
                        clearUsername();
                        history.push('/'+game+'/board');
                      }}>View</Button>
                  </Grid>
                </Grid>
              </Paper>
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </Paper>
  </Container>
)
};

Home.propTypes = {};

Home.defaultProps = {};

export default Home;
